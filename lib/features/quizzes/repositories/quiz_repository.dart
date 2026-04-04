import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/constants/firestore_constants.dart';
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

  Future<void> saveAttempt({
    required String uid,
    required QuizAttempt attempt,
  });

  Stream<List<QuizAttempt>> watchQuizHistory({
    required String uid,
    String? quizId,
  });

  Stream<QuizAttempt?> watchLastAttempt({
    required String uid,
    String? quizId,
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

  CollectionReference<Map<String, dynamic>> _attemptsRef(String uid) {
    return _db
        .collection(FirestoreConstants.users)
        .doc(uid)
        .collection(FirestoreConstants.quizAttempts);
  }

  @override
  Future<void> saveAttempt({
    required String uid,
    required QuizAttempt attempt,
  }) async {
    final completedAt = attempt.completedAt ?? DateTime.now();
    final data = <String, Object?>{
      'id': attempt.id,
      'quizId': attempt.quizId,
      'quizTitle': attempt.quizTitle,
      'score': attempt.score,
      'total': attempt.total,
      'score10': attempt.score10,
      'review': attempt.review
          .map((r) => {
                'q_id': r.qId,
                'user_choice': r.userChoice,
                'correct_choice': r.correctChoice,
                'is_correct': r.isCorrect,
              })
          .toList(),
      // Dùng Timestamp cụ thể để tránh null/pending khi order.
      'completedAt': Timestamp.fromDate(completedAt),
      'createdAt': Timestamp.fromDate(completedAt),
    };

    await _attemptsRef(uid).doc(attempt.id).set(data, SetOptions(merge: true));
  }

  QuizAttempt _attemptFromDoc(String id, Map<String, dynamic> data) {
    final normalized = <String, Object?>{...data, 'id': id};

    final completedAt = data['completedAt'];
    if (completedAt is Timestamp) {
      normalized['completedAt'] = completedAt.toDate().toIso8601String();
    } else if (completedAt is String) {
      normalized['completedAt'] = completedAt;
    }

    final reviewRaw = data['review'];
    if (reviewRaw is List) {
      normalized['review'] = _normalizeReviewList(reviewRaw);
    }

    final score10 = data['score10'];
    if (score10 is num) {
      normalized['score10'] = score10.toDouble();
    }

    return QuizAttempt.fromJson(normalized);
  }

  DateTime _sortKeyFromData(Map<String, dynamic> data) {
    final completedAt = data['completedAt'];
    if (completedAt is Timestamp) return completedAt.toDate();
    if (completedAt is String) {
      final parsed = DateTime.tryParse(completedAt);
      if (parsed != null) return parsed;
    }

    final createdAt = data['createdAt'];
    if (createdAt is Timestamp) return createdAt.toDate();
    if (createdAt is String) {
      final parsed = DateTime.tryParse(createdAt);
      if (parsed != null) return parsed;
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<void> _backfillAttemptTimestamps(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, dynamic> data,
  ) async {
    final updates = <String, Object?>{};

    final completedAt = data['completedAt'];
    DateTime? completedAtDate;
    if (completedAt is Timestamp) {
      completedAtDate = completedAt.toDate();
    } else if (completedAt is String) {
      completedAtDate = DateTime.tryParse(completedAt);
      if (completedAtDate != null) {
        updates['completedAt'] = Timestamp.fromDate(completedAtDate);
      }
    }

    final createdAt = data['createdAt'];
    if (createdAt == null && completedAtDate != null) {
      updates['createdAt'] = Timestamp.fromDate(completedAtDate);
    }

    if (updates.isEmpty) return;
    try {
      await doc.reference.set(updates, SetOptions(merge: true));
    } catch (_) {
      // Ignore migration failures; continue rendering history.
    }
  }

  List<QuizAttempt> _dedupeAndSort(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final map = <String, MapEntry<QuizAttempt, DateTime>>{};

    for (final d in docs) {
      final data = d.data();
      final attempt = _attemptFromDoc(d.id, data);
      final key = _sortKeyFromData(data);
      final dedupeKey = attempt.id.isNotEmpty ? attempt.id : d.id;

      final prev = map[dedupeKey];
      if (prev == null || key.isAfter(prev.value)) {
        map[dedupeKey] = MapEntry(attempt, key);
      }
    }

    final items = map.values.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return items.map((e) => e.key).toList();
  }

  @override
  Stream<List<QuizAttempt>> watchQuizHistory({
    required String uid,
    String? quizId,
  }) {
    final query = _attemptsRef(uid);

    return query.snapshots().map((snap) {
      for (final d in snap.docs) {
        _backfillAttemptTimestamps(d, d.data());
      }

      var items = _dedupeAndSort(snap.docs);

      if (quizId != null && quizId.trim().isNotEmpty) {
        items = items.where((a) => a.quizId == quizId).toList();
      }

      return items;
    });
  }

  @override
  Stream<QuizAttempt?> watchLastAttempt({
    required String uid,
    String? quizId,
  }) {
    final query = _attemptsRef(uid);

    return query.snapshots().map((snap) {
      final items = _dedupeAndSort(snap.docs);

      if (quizId == null || quizId.trim().isEmpty) {
        return items.isEmpty ? null : items.first;
      }

      return items.cast<QuizAttempt?>().firstWhere(
            (a) => a?.quizId == quizId,
            orElse: () => null,
          );
    });
  }

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

    final rawTimeLimit = data['timeLimit'] ?? data['time_limit'];
    if (rawTimeLimit is num) {
      normalized['timeLimit'] = rawTimeLimit.toInt();
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

  Map<String, String> _extractCorrectMap({
    required Map<String, dynamic> quizRaw,
    List<dynamic>? overrideList,
  }) {
    final rawCorrect = overrideList ?? quizRaw['correct_answers'];
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
    return correctMap;
  }

  List<Map<String, Object?>> _normalizeReviewList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) {
      final m = (e is Map)
          ? e.map((k, v) => MapEntry(k.toString(), v))
          : const <String, Object?>{};
      return <String, Object?>{
        'q_id': (m['q_id'] ?? m['qId'] ?? '').toString(),
        'user_choice': (m['user_choice'] ?? m['userChoice'] ?? '').toString(),
        'correct_choice':
            (m['correct_choice'] ?? m['correctChoice'] ?? '').toString(),
        'is_correct': (m['is_correct'] ?? m['isCorrect'] ?? false) == true,
      };
    }).toList();
  }

  List<Map<String, Object?>> _normalizeWrongList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) {
      final m = (e is Map)
          ? e.map((k, v) => MapEntry(k.toString(), v))
          : const <String, Object?>{};
      return <String, Object?>{
        'q_id': (m['q_id'] ?? m['qId'] ?? '').toString(),
        'user_choice': (m['user_choice'] ?? m['userChoice'] ?? '').toString(),
      };
    }).toList();
  }

  QuizGradingResult _gradeClientSideFromQuizDoc({
    required Map<String, dynamic> quizRaw,
    required Quiz quiz,
    required List<UserAnswer> answers,
    List<dynamic>? correctAnswersOverride,
  }) {
    final byQId = {
      for (final a in answers)
        a.qId.toString().trim(): a.userChoice.toString().trim(),
    };

    final correctMap = _extractCorrectMap(
      quizRaw: quizRaw,
      overrideList: correctAnswersOverride,
    );

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

    final answersByQId = <String, String>{
      for (final a in answers) a.qId: a.userChoice,
    };

    final payload = <String, Object?>{
      'quiz_id': quizId,
      'user_answers': answers
          .map((e) => {
                'q_id': e.qId,
                'user_choice': e.userChoice,
              })
          .toList(),
      // Gửi kèm map để tương thích nếu backend đọc theo dạng key-value.
      'answersByQId': answersByQId,
      'answers_by_qid': answersByQId,
      if (attemptId != null) 'attempt_id': attemptId,
    };

    // Tải raw quiz trước để có thể fallback local nhanh, không cần gọi lại network.
    final quizDoc = await _db.collection('quiz').doc(quizId).get();
    if (!quizDoc.exists) {
      throw StateError('Quiz not found: $quizId');
    }
    final quizRaw = quizDoc.data()!;
    final quiz = _quizFromDoc(quizDoc.id, quizRaw);

    // Có thể correct_answers nằm ở collection riêng.
    List<dynamic>? correctAnswersOverride;
    if (quizRaw['correct_answers'] is! List) {
      try {
        final answerDoc =
            await _db.collection('quiz_answers').doc(quizId).get();
        if (answerDoc.exists) {
          final data = answerDoc.data();
          if (data != null && data['correct_answers'] is List) {
            correctAnswersOverride = data['correct_answers'] as List<dynamic>;
          }
        }
      } catch (_) {
        // ignore fetch errors; fallback uses whatever is available.
      }
    }

    try {
      final res = await callable.call(payload);

      // Cloud Functions/Web thường trả về Map<Object?, Object?> / List<Object?>
      final raw = _deepJsonify(res.data);
      final data = (raw as Map).cast<String, dynamic>();

      final dynamic scoreRaw =
          data['score'] ?? data['correct_count'] ?? data['correctCount'];
      if (scoreRaw is num) data['score'] = scoreRaw.toInt();

      final dynamic totalRaw =
          data['total'] ?? data['total_questions'] ?? data['totalQuestions'];
      if (totalRaw is num) data['total'] = totalRaw.toInt();

      // Normalize completedAt
      final completedAt = data['completedAt'];
      if (completedAt is Timestamp) {
        data['completedAt'] = completedAt.toDate().toIso8601String();
      }

      // Normalize wrong_questions key (README)
      if (data['wrongQuestions'] == null && data['wrong_questions'] != null) {
        data['wrongQuestions'] = data['wrong_questions'];
      }
      if (data['wrongQuestions'] != null) {
        data['wrongQuestions'] = _normalizeWrongList(data['wrongQuestions']);
      }

      // Normalize review list
      if (data['review'] == null && data['reviews'] != null) {
        data['review'] = data['reviews'];
      }
      if (data['review'] != null) {
        data['review'] = _normalizeReviewList(data['review']);
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
          correctAnswersOverride: correctAnswersOverride,
        );
      }

      return result;
    } catch (_) {
      // Nếu callable fail (deploy/rules/network), fallback local để vẫn chấm được.
      return _gradeClientSideFromQuizDoc(
        quizRaw: quizRaw,
        quiz: quiz,
        answers: answers,
        correctAnswersOverride: correctAnswersOverride,
      );
    }
  }
}
