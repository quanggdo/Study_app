import '../models/flashcard_deck.dart';
import '../models/flashcard_card.dart';
import '../models/due_card.dart';
import '../models/review_state.dart';

abstract class FlashcardRepository {
  Stream<List<FlashcardDeck>> watchDecks({required String uId});

  Stream<List<FlashcardCard>> watchCards({
    required String uId,
    required String deckId,
  });

  Future<FlashcardDeck> createDeck({
    required String uId,
    required String title,
    String? description,
  });

  Future<FlashcardCard> createCard({
    required String uId,
    required String deckId,
    required String front,
    required String back,
    String? hint,
  });

  Future<void> updateCard({
    required String uId,
    required FlashcardCard card,
  });

  Future<void> deleteCard({
    required String uId,
    required FlashcardCard card,
  });

  Future<List<DueCard>> getDueCards({
    required String uId,
    required String deckId,
    required DateTime now,
    int limit = 100,
  });

  Future<ReviewState> getOrCreateReviewState({
    required String uId,
    required String deckId,
    required String cardId,
    DateTime? now,
  });

  Future<void> upsertReviewState(ReviewState state);
}
