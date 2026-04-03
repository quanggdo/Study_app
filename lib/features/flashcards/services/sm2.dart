/// SM-2 tối giản (giống Anki kiểu cơ bản) dùng cho lịch ôn flashcards.
///
/// Inputs:
/// - [quality] 0..5 (0=quên hoàn toàn, 5=nhớ rất tốt)
/// - [previous] trạng thái trước đó (có thể null)
///
/// Output:
/// - ReviewState mới (intervalDays, easeFactor, reps, lapses, dueAt)
///
/// Notes (tối giản):
/// - easeFactor không nhỏ hơn 1.3
/// - nếu quality < 3 => reset reps và intervalDays=1
library;

import '../models/review_state.dart';

class Sm2 {
  static const double _minEaseFactor = 1.3;

  static ReviewState grade({
    required ReviewState previous,
    required int quality,
    required DateTime now,
  }) {
    final q = quality.clamp(0, 5);

    var ease = previous.easeFactor;
    var reps = previous.reps;
    var lapses = previous.lapses;
    var interval = previous.intervalDays;

    if (q < 3) {
      reps = 0;
      lapses = lapses + 1;
      interval = 1;
    } else {
      reps = reps + 1;

      if (reps == 1) {
        interval = 1;
      } else if (reps == 2) {
        interval = 6;
      } else {
        interval = (interval * ease).round();
        if (interval < 1) interval = 1;
      }

      // SM-2 EF update
      ease = ease + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
      if (ease < _minEaseFactor) ease = _minEaseFactor;
    }

    return previous.copyWith(
      reps: reps,
      lapses: lapses,
      intervalDays: interval,
      easeFactor: ease,
      lastReviewedAt: now,
      updatedAt: now,
      dueAt: now.add(Duration(days: interval)),
    );
  }
}

