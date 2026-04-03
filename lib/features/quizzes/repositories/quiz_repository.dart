import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/services/firebase_firestore_service.dart';
import '../../../core/services/firebase_functions_service.dart';
import '../models/quiz_model.dart';
import '../models/quiz_result_model.dart';

abstract class QuizRepository {
  Stream<List<Quiz>> watchQuizzes();

  Stream<Quiz?> watchQuiz(String quizId);

  Future<QuizGradingResult> submitQuiz({
    required String quizId,
    required List<UserAnswer> answers,
    String? attemptId,
  });
}

class FirestoreQuizRepository implements QuizRepository {
  FirestoreQuizRepository({
    required FirebaseFirestoreService firestore,
    required FirebaseFunctionsService functions,
  })  : _firestore = firestore,
        _functions = functions;

  final FirebaseFirestoreService _firestore;
  final FirebaseFunctionsService _functions;

  FirebaseFirestore get _db => _firestore.instance;

  @override
  Stream<List<Quiz>> watchQuizzes() {
    return _db.collection('quiz').snapshots().map((snap) {
      final out = <Quiz>[];
      for (final d in snap.docs) {
        final data = d.data();
        out.add(_quizFromDoc(d.id, data));
      }
      out.sort((a, b) => a.title.compareTo(b.title));
      return out;
    });
  }

  @override
  Stream<Quiz?> watchQuiz(String quizId) {
    return _db.collection('quiz').doc(quizId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return _quizFromDoc(doc.id, doc.data()!);
    });
  }

  Quiz _quizFromDoc(String id, Map<String, dynamic> data) {
    final normalized = <String, Object?>{...data};

    final createdAt = data['createdAt'];
    if (createdAt is Timestamp) {
      normalized['createdAt'] = createdAt.toDate().toIso8601String();
    }

    final questions = data['questions'];
    if (questions is List) {
      normalized['questions'] = questions.map((q) {
        if (q is! Map) return q;
        final qm = q.map((k, v) => MapEntry(k.toString(), v));

        // Firestore hiện tại: field question có thể là `thrilled` (typo) thay vì `question`
        final questionText = (qm['question'] ?? qm['thrilled'] ?? '').toString();

        // Firestore hiện tại: danh sách lựa chọn có thể là `options` thay vì `choices`
        final rawChoices = qm['choices'] ?? qm['options'];
        List mappedChoices = const [];
        if (rawChoices is List) {
          mappedChoices = rawChoices.map((c) {
            if (c is! Map) return c;
            final cm = c.map((k, v) => MapEntry(k.toString(), v));
            return {
              // Firestore: `opt_id` hoặc `id` hoặc `value`
              'id': (cm['id'] ?? cm['opt_id'] ?? cm['value'] ?? '').toString(),
              'text': (cm['text'] ?? cm['label'] ?? '').toString(),
            };
          }).toList();
        }

        return {
          ...qm,
          // giữ chuẩn key cho app parse
          'q_id': (qm['q_id'] ?? qm['qId'] ?? '').toString(),
          'question': questionText,
          'choices': mappedChoices,
        };
      }).toList();
    }

    return Quiz.fromJson(<String, Object?>{
      ...normalized,
      'id': id,
      'title': (data['title'] ?? '').toString(),
    });
  }

  dynamic _deepJsonify(dynamic v) {
    if (v is Map) {
      return v.map((key, value) => MapEntry(key.toString(), _deepJsonify(value)));
    }
    if (v is List) {
      return v.map(_deepJsonify).toList();
    }
    return v;
  }

  QuizGradingResult _gradeClientSideFromQuizDoc({
    required Map<String, dynamic> quizRaw,
    required Quiz quiz,
    required List<UserAnswer> answers,
  }) {
    final byQId = {
      for (final a in answers)
        a.qId.toString().trim(): a.userChoice.toString().trim(),
    };

    // Parse correct_answers[] từ quiz doc hiện tại
    final rawCorrect = quizRaw['correct_answers'];
    final correctMap = <String, String>{};
    if (rawCorrect is List) {
      for (final item in rawCorrect) {
        if (item is! Map) continue;
        final m = item.map((k, v) => MapEntry(k.toString(), v));
        final qId = (m['q_id'] ?? m['qId'] ?? '').toString().trim();
        final opt =
            (m['correct_opt_id'] ?? m['correctOptId'] ?? '').toString().trim();
        if (qId.isNotEmpty && opt.isNotEmpty) {
          correctMap[qId] = opt;
        }
      }
    }

    final review = <QuizReviewItem>[];
    final wrong = <UserAnswer>[];
    var score = 0;

    for (final q in quiz.questions) {
      final qId = q.qId.toString().trim();
      final userChoice = (byQId[qId] ?? '').toString().trim();
      final correctChoice = (correctMap[qId] ?? '').toString().trim();

      final isCorrect = userChoice.isNotEmpty &&
          correctChoice.isNotEmpty &&
          userChoice.toLowerCase() == correctChoice.toLowerCase();

      if (isCorrect) {
        score += 1;
      } else {
        wrong.add(UserAnswer(qId: qId, userChoice: userChoice));
      }

      review.add(
        QuizReviewItem(
          qId: qId,
          userChoice: userChoice,
          correctChoice: correctChoice,
          isCorrect: isCorrect,
        ),
      );
    }

    return QuizGradingResult(
      score: score,
      total: quiz.questions.length,
      wrongQuestions: wrong,
      review: review,
      completedAt: DateTime.now(),
    );
  }

  @override
  Future<QuizGradingResult> submitQuiz({
    required String quizId,
    required List<UserAnswer> answers,
    String? attemptId,
  }) async {
    final callable = _functions.instance.httpsCallable(
      'gradeQuiz',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
    );

    final payload = <String, Object?>{
      'quiz_id': quizId,
      'user_answers': answers
          .map((e) => {
                'q_id': e.qId,
                'user_choice': e.userChoice,
              })
          .toList(),
      if (attemptId != null) 'attempt_id': attemptId,
    };

    // Tải raw quiz trước để có thể fallback local nhanh, không cần gọi lại network.
    final quizDoc = await _db.collection('quiz').doc(quizId).get();
    if (!quizDoc.exists) {
      throw StateError('Quiz not found: $quizId');
    }
    final quizRaw = quizDoc.data()!;
    final quiz = _quizFromDoc(quizDoc.id, quizRaw);

    try {
      final res = await callable.call(payload);

      // Cloud Functions/Web thường trả về Map<Object?, Object?> / List<Object?>
      final raw = _deepJsonify(res.data);
      final data = (raw as Map).cast<String, dynamic>();

      // Normalize completedAt
      final completedAt = data['completedAt'];
      if (completedAt is Timestamp) {
        data['completedAt'] = completedAt.toDate().toIso8601String();
      }

      // Normalize wrong_questions key (README)
      if (data['wrong_questions'] is List && data['wrongQuestions'] == null) {
        data['wrongQuestions'] = data['wrong_questions'];
      }

      final result = QuizGradingResult.fromJson(data);

      // Nếu server trả review rỗng hoặc thiếu correctChoice, fallback local để người dùng vẫn xem được đáp án.
      final hasReview = result.review.isNotEmpty;
      final hasCorrectChoice =
          result.review.any((r) => r.correctChoice.trim().isNotEmpty);
      if (!hasReview || !hasCorrectChoice) {
        return _gradeClientSideFromQuizDoc(
          quizRaw: quizRaw,
          quiz: quiz,
          answers: answers,
        );
      }

      return result;
    } catch (_) {
      // Nếu callable fail (deploy/rules/network), fallback local để vẫn chấm được.
      return _gradeClientSideFromQuizDoc(
        quizRaw: quizRaw,
        quiz: quiz,
        answers: answers,
      );
    }
  }
}
