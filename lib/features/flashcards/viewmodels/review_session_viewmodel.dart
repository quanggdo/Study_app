import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/viewmodels/auth_viewmodel.dart';
import '../models/due_card.dart';
import '../models/review_state.dart';
import '../repositories/isar_flashcard_repository.dart';
import '../repositories/flashcard_repository_contract.dart';
import '../services/sm2.dart';

enum ReviewGrade { again, hard, good, easy }

extension ReviewGradeX on ReviewGrade {
  int get quality {
    switch (this) {
      case ReviewGrade.again:
        return 1;
      case ReviewGrade.hard:
        return 3;
      case ReviewGrade.good:
        return 4;
      case ReviewGrade.easy:
        return 5;
    }
  }
}

class ReviewSessionState {
  const ReviewSessionState({
    this.loading = true,
    this.error,
    this.items = const [],
    this.index = 0,
    this.showAnswer = false,
    this.lastScheduledMessage,
  });

  final bool loading;
  final Object? error;
  final List<DueCard> items;
  final int index;
  final bool showAnswer;
  final String? lastScheduledMessage;

  DueCard? get current => index >= 0 && index < items.length ? items[index] : null;
  int get total => items.length;
  int get remaining => max(0, items.length - index);

  ReviewSessionState copyWith({
    bool? loading,
    Object? error,
    List<DueCard>? items,
    int? index,
    bool? showAnswer,
    String? lastScheduledMessage,
  }) {
    return ReviewSessionState(
      loading: loading ?? this.loading,
      error: error,
      items: items ?? this.items,
      index: index ?? this.index,
      showAnswer: showAnswer ?? this.showAnswer,
      lastScheduledMessage: lastScheduledMessage,
    );
  }
}

class ReviewSessionViewModel extends StateNotifier<ReviewSessionState> {
  ReviewSessionViewModel({
    required this.repo,
    required this.uId,
    required this.deckId,
    int limit = 20,
  })  : _limit = limit,
        super(const ReviewSessionState()) {
    load();
  }

  final FlashcardRepository repo;
  final String uId;
  final String deckId;
  final int _limit;

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null, lastScheduledMessage: null);
    try {
      final items = await repo.getDueCards(
        uId: uId,
        deckId: deckId,
        now: DateTime.now(),
        limit: _limit,
      );

      state = state.copyWith(
        loading: false,
        items: items,
        index: 0,
        showAnswer: false,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e);
    }
  }

  void revealAnswer() {
    if (state.current == null) return;
    state = state.copyWith(showAnswer: true);
  }

  String _formatScheduleMessage({
    required DateTime now,
    required ReviewState next,
    required ReviewGrade grade,
  }) {
    final days = next.intervalDays;
    final due = next.dueAt;
    final diff = due.difference(now);
    final minutes = diff.inMinutes;

    final label = switch (grade) {
      ReviewGrade.again => 'Again',
      ReviewGrade.hard => 'Hard',
      ReviewGrade.good => 'Good',
      ReviewGrade.easy => 'Easy',
    };

    // Nếu intervalDays = 0/1 thì hiển thị theo phút/giờ cho dễ thấy khi test
    if (minutes < 60) {
      return '$label • Hẹn lại sau $minutes phút';
    }
    final hours = diff.inHours;
    if (hours < 48) {
      return '$label • Hẹn lại sau $hours giờ';
    }

    return '$label • Hẹn lại sau $days ngày (đến hạn: ${due.toLocal().toString().substring(0, 16)})';
  }

  Future<void> grade(ReviewGrade grade) async {
    final current = state.current;
    if (current == null) return;

    final now = DateTime.now();

    final prev = current.state ??
        await repo.getOrCreateReviewState(
          uId: uId,
          deckId: deckId,
          cardId: current.card.id,
          now: now,
        );

    final next = Sm2.grade(
      previous: prev,
      quality: grade.quality,
      now: now,
    );

    await repo.upsertReviewState(next);

    // Loại thẻ vừa chấm khỏi danh sách due hiện tại để người dùng thấy tác dụng ngay.
    final updated = [...state.items];
    updated.removeAt(state.index);

    final newIndex = min(state.index, max(0, updated.length));

    state = state.copyWith(
      items: updated,
      index: newIndex,
      showAnswer: false,
      lastScheduledMessage: _formatScheduleMessage(now: now, next: next, grade: grade),
    );
  }

  /// Dự đoán lịch hẹn cho từng grade để hiển thị trên UI (Anki-like) trước khi bấm.
  /// Lưu ý: với thẻ chưa có state, dùng state mặc định từ repo.
  Future<ReviewState?> previewNextState(ReviewGrade grade) async {
    final current = state.current;
    if (current == null) return null;

    final now = DateTime.now();

    final prev = current.state ??
        await repo.getOrCreateReviewState(
          uId: uId,
          deckId: deckId,
          cardId: current.card.id,
          now: now,
        );

    return Sm2.grade(
      previous: prev,
      quality: grade.quality,
      now: now,
    );
  }
}

final reviewSessionProvider = StateNotifierProvider.autoDispose
    .family<ReviewSessionViewModel, ReviewSessionState, String>((ref, deckId) {
  final auth = ref.watch(authNotifierProvider);
  final uId = auth.user?.uid;
  if (uId == null) {
    throw StateError('User not authenticated');
  }

  final repo = ref.watch(flashcardRepositoryProvider);
  return ReviewSessionViewModel(
    repo: repo,
    uId: uId,
    deckId: deckId,
  );
});
