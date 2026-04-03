import '../../models/due_card.dart';
import '../../models/flashcard_card.dart';
import '../../models/flashcard_deck.dart';
import '../../models/review_state.dart';

// Web stub for Isar local layer.
//
// Purpose: avoid importing any Isar entities / generated `*.g.dart` on Web.
// Các method ở đây chỉ để compile; sẽ không được gọi (web dùng Firestore/InMemory).
class IsarFlashcardLocalDatasource {
  IsarFlashcardLocalDatasource(dynamic _);

  Stream<List<FlashcardDeck>> watchDecks({required String uId}) =>
      const Stream<List<FlashcardDeck>>.empty();

  Stream<List<FlashcardCard>> watchCards({
    required String uId,
    required String deckId,
  }) =>
      const Stream<List<FlashcardCard>>.empty();

  Future<void> upsertDeck(FlashcardDeck deck) async {}

  Future<void> upsertCard(FlashcardCard card) async {}

  Future<List<DueCard>> getDueCards({
    required String uId,
    required String deckId,
    required DateTime now,
    int limit = 20,
  }) async =>
      const <DueCard>[];

  Future<ReviewState> getOrCreateReviewState({
    required String uId,
    required String deckId,
    required String cardId,
    DateTime? now,
  }) async =>
      ReviewState(
        cardId: cardId,
        deckId: deckId,
        uId: uId,
        dueAt: now ?? DateTime.now(),
        updatedAt: now ?? DateTime.now(),
      );

  Future<void> upsertReviewState(ReviewState state) async {}
}
