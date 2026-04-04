import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/viewmodels/auth_viewmodel.dart';
import '../models/due_card.dart';
import '../models/flashcard_card.dart';
import '../models/review_state.dart';
import '../repositories/isar_flashcard_repository.dart';
import '../repositories/flashcard_repository_contract.dart';
import '../services/sm2.dart';

class ReviewSessionParams {
  const ReviewSessionParams({
    required this.deckId,
    required this.includeAllCards,
  });

  final String deckId;
  final bool includeAllCards;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewSessionParams &&
        other.deckId == deckId &&
        other.includeAllCards == includeAllCards;
  }

  @override
  int get hashCode => Object.hash(deckId, includeAllCards);
}

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
    this.initialTotal = 0,
    this.repeatedCount = 0,
    this.reviewedCount = 0,
    this.showAnswer = false,
    this.lastScheduledMessage,
  });

  final bool loading;
  final Object? error;
  final List<DueCard> items;
  final int index;
  final int initialTotal;
  final int repeatedCount;
  final int reviewedCount;
  final bool showAnswer;
  final String? lastScheduledMessage;

  DueCard? get current => index >= 0 && index < items.length ? items[index] : null;
  int get total => initialTotal + repeatedCount;
  int get remaining => items.length;

  ReviewSessionState copyWith({
    bool? loading,
    Object? error,
    List<DueCard>? items,
    int? index,
    int? initialTotal,
    int? repeatedCount,
    int? reviewedCount,
    bool? showAnswer,
    String? lastScheduledMessage,
  }) {
    return ReviewSessionState(
      loading: loading ?? this.loading,
      error: error,
      items: items ?? this.items,
      index: index ?? this.index,
      initialTotal: initialTotal ?? this.initialTotal,
      repeatedCount: repeatedCount ?? this.repeatedCount,
      reviewedCount: reviewedCount ?? this.reviewedCount,
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
    required this.includeAllCards,
    int limit = 1000,
  })  : _limit = limit,
        super(const ReviewSessionState()) {
    load();
  }

  final FlashcardRepository repo;
  final String uId;
  final String deckId;
  final bool includeAllCards;
  final int _limit;

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null, lastScheduledMessage: null);
    try {
      final now = DateTime.now();

      final List<DueCard> items;
      if (includeAllCards) {
        final cards = await repo.watchCards(uId: uId, deckId: deckId).first;
        items = await Future.wait(cards.map((FlashcardCard card) async {
          final state = await repo.getOrCreateReviewState(
            uId: uId,
            deckId: deckId,
            cardId: card.id,
            now: now,
          );
          return DueCard(card: card, state: state);
        }));
      } else {
        items = await repo.getDueCards(
          uId: uId,
          deckId: deckId,
          now: now,
          limit: _limit,
        );
      }

      state = state.copyWith(
        loading: false,
        items: items,
        index: 0,
        initialTotal: items.length,
        repeatedCount: 0,
        reviewedCount: 0,
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

  void toggleAnswer() {
    if (state.current == null) return;
    state = state.copyWith(showAnswer: !state.showAnswer);
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

    var repeatedCount = state.repeatedCount;
    if (grade == ReviewGrade.again) {
      // Đưa thẻ xuống cuối phiên để người dùng thấy tác dụng của Again ngay.
      updated.add(DueCard(card: current.card, state: next));
      repeatedCount += 1;
    }

    final newIndex = updated.isEmpty ? 0 : min(state.index, updated.length - 1);

    state = state.copyWith(
      items: updated,
      index: newIndex,
      repeatedCount: repeatedCount,
      reviewedCount: state.reviewedCount + 1,
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
    .family<ReviewSessionViewModel, ReviewSessionState, ReviewSessionParams>((ref, params) {
  final auth = ref.watch(authNotifierProvider);
  final uId = auth.user?.uid;
  if (uId == null) {
    throw StateError('User not authenticated');
  }

  final repo = ref.watch(flashcardRepositoryProvider);
  return ReviewSessionViewModel(
    repo: repo,
    uId: uId,
    deckId: params.deckId,
    includeAllCards: params.includeAllCards,
  );
});
