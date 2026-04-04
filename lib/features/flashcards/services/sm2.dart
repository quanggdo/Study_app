/// SM-2 + learning steps (Anki-ish) dùng cho lịch ôn flashcards.
//
// - Giai đoạn Learning: lặp lại theo phút (1m -> 10m).
// - Khi qua learning steps sẽ chuyển sang Review, dùng SM-2 theo ngày.
//
// Mapping quality (0..5):
// - 0..2: Again (fail)
// - 3: Hard
// - 4: Good
// - 5: Easy
library;

import '../models/review_state.dart';

class Sm2 {
  static const double _minEaseFactor = 1.3;

  // Learning steps (phút) kiểu Anki (mặc định phổ biến là 1m -> 10m).
  // Again: quay về 1m
  // Good: tiến step tiếp theo
  // Easy: graduate sớm (ra review)
  static const List<int> _learningStepsMinutes = [1, 10];

  // Hard trong learning: Anki thường cho thời gian ngắn hơn Good của step hiện tại.
  // Với step=10m thì Hard ~ 6m (0.6x) giúp khác biệt rõ với Again(1m) và Good(10m).
  static const double _hardLearningMultiplier = 0.6;

  static ReviewState grade({
    required ReviewState previous,
    required int quality,
    required DateTime now,
  }) {
    final q = quality.clamp(0, 5);

    // Nếu đang learning => xử lý learning steps
    if (previous.stateType == ReviewStateType.learning) {
      return _gradeLearning(previous: previous, q: q, now: now);
    }

    // Review stage (SM-2 theo ngày)
    return _gradeReview(previous: previous, q: q, now: now);
  }

  static ReviewState _gradeLearning({
    required ReviewState previous,
    required int q,
    required DateTime now,
  }) {
    final isNew = previous.reps == 0 && previous.intervalMinutes == 0;

    // Again: quay về step 1
    if (q < 3) {
      return previous.copyWith(
        stateType: ReviewStateType.learning,
        reps: 0,
        lapses: previous.lapses + 1,
        intervalDays: 0,
        intervalMinutes: _learningStepsMinutes.first,
        lastReviewedAt: now,
        updatedAt: now,
        dueAt: now.add(Duration(minutes: _learningStepsMinutes.first)),
      );
    }

    // Hard: Anki-ish => lặp lại sớm hơn Good (không quay về 1m như Again).
    if (q == 3) {
      // Với thẻ mới (chưa có interval), Anki preview: Hard=6m, Good=10m.
      // => coi như current step mục tiêu là 10m để tính Hard.
      final stepForHard = isNew ? _learningStepsMinutes.last : previous.intervalMinutes;

      final currentStep = stepForHard > 0 ? stepForHard : _learningStepsMinutes.first;

      // Nếu đang ở step 1m thì Hard vẫn là 1m.
      // Nếu đang ở step 10m thì Hard ~ 6m.
      final hardMinutes = currentStep <= _learningStepsMinutes.first
          ? _learningStepsMinutes.first
          : (currentStep * _hardLearningMultiplier).round().clamp(
                _learningStepsMinutes.first,
                currentStep,
              );

      final reps = previous.reps + 1;
      return previous.copyWith(
        stateType: ReviewStateType.learning,
        reps: reps,
        intervalDays: 0,
        intervalMinutes: hardMinutes,
        lastReviewedAt: now,
        updatedAt: now,
        dueAt: now.add(Duration(minutes: hardMinutes)),
      );
    }

    // Easy: Anki thường graduate sớm ngay từ bước đầu.
    if (q == 5 && isNew) {
      const firstIntervalDays = 4;
      return previous.copyWith(
        stateType: ReviewStateType.review,
        reps: previous.reps + 1,
        intervalMinutes: 0,
        intervalDays: firstIntervalDays,
        easeFactor: (previous.easeFactor + 0.15).clamp(_minEaseFactor, 10.0),
        lastReviewedAt: now,
        updatedAt: now,
        dueAt: now.add(const Duration(days: firstIntervalDays)),
      );
    }

    // Good/Easy: tiến step
    // Nếu state mới (intervalMinutes=0), coi như Good sẽ nhảy thẳng lên step tiếp theo (10m)
    // thay vì rơi vào step đầu (1m), để khớp UI Anki: Good 10m ở lần học đầu.
    final currentStep = previous.intervalMinutes > 0
        ? previous.intervalMinutes
        : (isNew ? _learningStepsMinutes.first : _learningStepsMinutes.first);

    final idx = _learningStepsMinutes.indexOf(currentStep);

    final nextIdx = previous.intervalMinutes == 0 && isNew
        ? 1
        : (idx >= 0 ? idx + 1 : 0);

    // Nếu hết steps => chuyển sang review
    if (nextIdx >= _learningStepsMinutes.length) {
      // interval ngày đầu sau khi graduate: Good=1d, Easy=4d
      final firstIntervalDays = (q == 5) ? 4 : 1;
      return previous.copyWith(
        stateType: ReviewStateType.review,
        reps: previous.reps + 1,
        intervalMinutes: 0,
        intervalDays: firstIntervalDays,
        easeFactor: q == 5
            ? (previous.easeFactor + 0.15).clamp(_minEaseFactor, 10.0)
            : previous.easeFactor,
        lastReviewedAt: now,
        updatedAt: now,
        dueAt: now.add(Duration(days: firstIntervalDays)),
      );
    }

    final step = _learningStepsMinutes[nextIdx];
    return previous.copyWith(
      stateType: ReviewStateType.learning,
      reps: previous.reps + 1,
      intervalDays: 0,
      intervalMinutes: step,
      lastReviewedAt: now,
      updatedAt: now,
      dueAt: now.add(Duration(minutes: step)),
    );
  }

  static ReviewState _gradeReview({
    required ReviewState previous,
    required int q,
    required DateTime now,
  }) {
    var ease = previous.easeFactor;
    var reps = previous.reps;
    var lapses = previous.lapses;
    var interval = previous.intervalDays;

    if (q < 3) {
      // Lapse => quay lại learning steps
      lapses = lapses + 1;
      reps = 0;
      final step = _learningStepsMinutes.first;
      return previous.copyWith(
        stateType: ReviewStateType.learning,
        reps: reps,
        lapses: lapses,
        intervalDays: 0,
        intervalMinutes: step,
        lastReviewedAt: now,
        updatedAt: now,
        dueAt: now.add(Duration(minutes: step)),
      );
    }

    reps = reps + 1;

    if (reps == 1) {
      interval = 1;
    } else if (reps == 2) {
      interval = 6;
    } else {
      // SM-2 base
      interval = (interval * ease).round();
      if (interval < 1) interval = 1;
    }

    // Hard/Good/Easy tweak
    if (q == 3) {
      interval = (interval * 0.8).round();
      if (interval < 1) interval = 1;
    } else if (q == 5) {
      interval = (interval * 1.3).round();
    }

    // SM-2 EF update
    ease = ease + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
    if (ease < _minEaseFactor) ease = _minEaseFactor;

    return previous.copyWith(
      stateType: ReviewStateType.review,
      reps: reps,
      lapses: lapses,
      intervalMinutes: 0,
      intervalDays: interval,
      easeFactor: ease,
      lastReviewedAt: now,
      updatedAt: now,
      dueAt: now.add(Duration(days: interval)),
    );
  }
}
