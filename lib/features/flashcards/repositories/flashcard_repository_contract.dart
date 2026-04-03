import '../models/flashcard_deck.dart';
import '../models/flashcard_card.dart';

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
}
