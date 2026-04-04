import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/user_provider.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../../core/providers/firebase_functions_provider.dart';
import '../models/quiz_model.dart';
import '../models/quiz_result_model.dart';
import '../repositories/quiz_repository.dart';

part 'quiz_viewmodel.freezed.dart';

@freezed
class QuizSessionState with _$QuizSessionState {
  const factory QuizSessionState({
    @Default(true) bool loading,
    Quiz? quiz,
    @Default(0) int index,
    @Default({}) Map<String, String> answersByQId,
    @Default(false) bool submitting,
    QuizGradingResult? result,
    Object? error,
    int? remainingSeconds,
    @Default(false) bool timeUp,
    DateTime? endAt,
  }) = _QuizSessionState;
}

class QuizSessionViewModel extends StateNotifier<QuizSessionState> {
  QuizSessionViewModel({
    required this.repo,
    required this.quizId,
    required this.ref,
  }) : super(const QuizSessionState()) {
    _sub = repo.watchQuiz(quizId).listen(
      (q) {
        if (q != null) {
          _startTimerIfNeeded(q);
        }
        state = state.copyWith(loading: false, quiz: q, error: null);
      },
      onError: (e) {
        state = state.copyWith(loading: false, error: e);
      },
    );
  }

  final QuizRepository repo;
  final String quizId;
  final Ref ref;

  late final StreamSubscription _sub;

  Timer? _timer;

  void _startTimerIfNeeded(Quiz quiz) {
    // Only start once
    if (_timer != null) return;

    final minutes = quiz.timeLimit;
    if (minutes == null || minutes <= 0) {
      state = state.copyWith(remainingSeconds: null, endAt: null);
      return;
    }

    final now = DateTime.now();
    final endAt = state.endAt ?? now.add(Duration(minutes: minutes));
    state = state.copyWith(
      endAt: endAt,
      remainingSeconds: _remainingFromEnd(endAt),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      // nếu đã có kết quả hoặc đang submit thì thôi
      if (state.result != null) {
        t.cancel();
        return;
      }

      final remaining = _remainingFromEnd(state.endAt);
      if (remaining <= 0) {
        t.cancel();
        state = state.copyWith(remainingSeconds: 0, timeUp: true);
        // Auto submit khi hết giờ
        await submit(auto: true);
      } else {
        state = state.copyWith(remainingSeconds: remaining);
      }
    });
  }

  int _remainingFromEnd(DateTime? endAt) {
    if (endAt == null) return 0;
    final diff = endAt.difference(DateTime.now()).inSeconds;
    return diff < 0 ? 0 : diff;
  }

  void refreshRemaining() {
    final endAt = state.endAt;
    if (endAt == null || state.result != null) return;

    final remaining = _remainingFromEnd(endAt);
    if (remaining <= 0) {
      state = state.copyWith(remainingSeconds: 0, timeUp: true);
      // Force submit when coming back after time is up.
      unawaited(submit(auto: true));
    } else {
      state = state.copyWith(remainingSeconds: remaining);
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    _timer?.cancel();
    super.dispose();
  }

  QuizQuestion? get currentQuestion {
    final q = state.quiz;
    if (q == null) return null;
    if (state.index < 0 || state.index >= q.questions.length) return null;
    return q.questions[state.index];
  }

  void selectChoice({required String qId, required String choiceId}) {
    state = state.copyWith(
      answersByQId: {...state.answersByQId, qId: choiceId},
    );
  }

  void next() {
    final q = state.quiz;
    if (q == null) return;
    if (state.index + 1 >= q.questions.length) return;
    state = state.copyWith(index: state.index + 1);
  }

  void back() {
    if (state.index <= 0) return;
    state = state.copyWith(index: state.index - 1);
  }

  double _score10(int score, int total) {
    if (total <= 0) return 0;
    return (score * 10 / total).clamp(0, 10).toDouble();
  }

  Future<void> submit({bool auto = false}) async {
    final quiz = state.quiz;
    if (quiz == null) return;
    if (state.submitting || state.result != null) return;

    final answers = quiz.questions
        .map((qq) => UserAnswer(
              qId: qq.qId,
              userChoice: state.answersByQId[qq.qId] ?? '',
            ))
        .toList();

    state = state.copyWith(submitting: true, error: null);
    try {
      final attemptId = const Uuid().v4();
      final result = await repo.submitQuiz(
        quizId: quiz.id,
        answers: answers,
        attemptId: attemptId,
      );

      final user = ref.read(currentUserProvider);
      if (user != null) {
        final attempt = QuizAttempt(
          id: attemptId,
          quizId: quiz.id,
          quizTitle: quiz.title,
          score: result.score,
          total: result.total,
          score10: _score10(result.score, result.total),
          review: result.review,
          completedAt: result.completedAt ?? DateTime.now(),
        );
        await repo.saveAttempt(uid: user.uid, attempt: attempt);
      }

      state = state.copyWith(submitting: false, result: result);
    } catch (e) {
      state = state.copyWith(submitting: false, error: e);
      if (auto) {
        // auto-submit failure: giữ timeUp=true để UI thông báo
        state = state.copyWith(timeUp: true);
      }
    }
  }

  int get answeredCount => state.answersByQId.length;

  void jumpTo(int newIndex) {
    final q = state.quiz;
    if (q == null) return;
    if (newIndex < 0 || newIndex >= q.questions.length) return;
    state = state.copyWith(index: newIndex);
  }
}

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreServiceProvider);
  final functions = ref.watch(firebaseFunctionsServiceProvider);
  return FirestoreQuizRepository(firestore: firestore, functions: functions);
});

final quizSessionProvider = StateNotifierProvider.autoDispose
    .family<QuizSessionViewModel, QuizSessionState, String>((ref, quizId) {
  final repo = ref.watch(quizRepositoryProvider);
  return QuizSessionViewModel(repo: repo, quizId: quizId, ref: ref);
});

final quizHistoryProvider = StreamProvider.family
    .autoDispose<List<QuizAttempt>, String?>((ref, quizId) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  final repo = ref.watch(quizRepositoryProvider);
  return repo.watchQuizHistory(uid: user.uid, quizId: quizId);
});

final lastQuizAttemptProvider = StreamProvider.family
    .autoDispose<QuizAttempt?, String?>((ref, quizId) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  final repo = ref.watch(quizRepositoryProvider);
  return repo.watchLastAttempt(uid: user.uid, quizId: quizId);
});
