import 'package:flutter_test/flutter_test.dart';
import 'package:student_academic_assistant/features/flashcards/models/review_state.dart';
import 'package:student_academic_assistant/features/flashcards/services/sm2.dart';

void main() {
  test('Anki-ish: Again in learning schedules 1 minute', () {
    final now = DateTime(2026, 1, 1, 0, 0);
    final prev = ReviewState(
      cardId: 'c1',
      deckId: 'd1',
      uId: 'u1',
      dueAt: now,
      reps: 5,
      lapses: 0,
      intervalDays: 10,
      intervalMinutes: 10,
      stateType: ReviewStateType.learning,
      easeFactor: 2.5,
      updatedAt: now,
    );

    final next = Sm2.grade(previous: prev, quality: 0, now: now);
    expect(next.reps, 0);
    expect(next.lapses, 1);
    expect(next.stateType, ReviewStateType.learning);
    expect(next.intervalMinutes, 1);
    expect(next.dueAt, now.add(const Duration(minutes: 1)));
  });

  test('Anki-ish: Good in learning advances to 10 minutes', () {
    final now = DateTime(2026, 1, 1, 0, 0);
    final prev = ReviewState(
      cardId: 'c1',
      deckId: 'd1',
      uId: 'u1',
      dueAt: now,
      reps: 0,
      lapses: 0,
      intervalDays: 0,
      intervalMinutes: 1,
      stateType: ReviewStateType.learning,
      easeFactor: 2.5,
      updatedAt: now,
    );

    final next = Sm2.grade(previous: prev, quality: 4, now: now);
    expect(next.stateType, ReviewStateType.learning);
    expect(next.intervalMinutes, 10);
    expect(next.dueAt, now.add(const Duration(minutes: 10)));
  });

  test('Anki-ish: Graduate to review after finishing steps', () {
    final now = DateTime(2026, 1, 1, 0, 0);
    final prev = ReviewState(
      cardId: 'c1',
      deckId: 'd1',
      uId: 'u1',
      dueAt: now,
      reps: 1,
      lapses: 0,
      intervalDays: 0,
      intervalMinutes: 10,
      stateType: ReviewStateType.learning,
      easeFactor: 2.5,
      updatedAt: now,
    );

    final next = Sm2.grade(previous: prev, quality: 4, now: now);
    expect(next.stateType, ReviewStateType.review);
    expect(next.intervalDays, 1);
    expect(next.dueAt, now.add(const Duration(days: 1)));
  });
}
