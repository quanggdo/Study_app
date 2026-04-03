import 'package:isar/isar.dart';

import '../../models/flashcard_card.dart';
import '../../models/flashcard_deck.dart';
import 'flashcard_card_entity.dart';
import 'flashcard_deck_entity.dart';

class IsarFlashcardLocalDatasource {
  IsarFlashcardLocalDatasource(this._isar);

  final Isar _isar;

  Stream<List<FlashcardDeck>> watchDecks({required String uId}) {
    return _isar.flashcardDeckEntitys
        .where()
        .uIdEqualTo(uId)
        .filter()
        .isDeletedEqualTo(false)
        .sortByUpdatedAtDesc()
        .watch(fireImmediately: true)
        .map((entities) => entities
            .map(
              (e) => FlashcardDeck(
                id: e.id,
                uId: e.uId,
                title: e.title,
                description: e.description,
                tags: e.tags,
                cardCount: e.cardCount,
                lastStudiedAt: e.lastStudiedAt,
                createdAt: e.createdAt,
                updatedAt: e.updatedAt,
                isDeleted: e.isDeleted,
              ),
            )
            .toList(growable: false));
  }

  Stream<List<FlashcardCard>> watchCards({
    required String uId,
    required String deckId,
  }) {
    return _isar.flashcardCardEntitys
        .where()
        .uIdEqualTo(uId)
        .filter()
        .deckIdEqualTo(deckId)
        .isDeletedEqualTo(false)
        .sortByUpdatedAtDesc()
        .watch(fireImmediately: true)
        .map((entities) => entities
            .map(
              (e) => FlashcardCard(
                id: e.id,
                deckId: e.deckId,
                uId: e.uId,
                front: e.front,
                back: e.back,
                hint: e.hint,
                createdAt: e.createdAt,
                updatedAt: e.updatedAt,
                isDeleted: e.isDeleted,
              ),
            )
            .toList(growable: false));
  }

  Future<void> upsertCard(FlashcardCard card) async {
    await _isar.writeTxn(() async {
      final entity = FlashcardCardEntity(
        id: card.id,
        deckId: card.deckId,
        uId: card.uId,
        front: card.front,
        back: card.back,
        hint: card.hint,
        createdAt: card.createdAt,
        updatedAt: card.updatedAt,
        isDeleted: card.isDeleted,
      );

      await _isar.flashcardCardEntitys.put(entity);

      // cập nhật cardCount cho deck (best-effort)
      final deck = await _isar.flashcardDeckEntitys
          .where()
          .idEqualTo(card.deckId)
          .findFirst();
      if (deck != null) {
        final count = await _isar.flashcardCardEntitys
            .where()
            .deckIdEqualTo(card.deckId)
            .filter()
            .isDeletedEqualTo(false)
            .count();
        deck.cardCount = count;
        deck.updatedAt = DateTime.now();
        await _isar.flashcardDeckEntitys.put(deck);
      }
    });
  }

  Future<void> upsertDeck(FlashcardDeck deck) async {
    await _isar.writeTxn(() async {
      final entity = FlashcardDeckEntity(
        id: deck.id,
        uId: deck.uId,
        title: deck.title,
        description: deck.description,
        tags: deck.tags,
        cardCount: deck.cardCount,
        lastStudiedAt: deck.lastStudiedAt,
        createdAt: deck.createdAt,
        updatedAt: deck.updatedAt,
        isDeleted: deck.isDeleted,
      );

      await _isar.flashcardDeckEntitys.put(entity);
    });
  }
}
