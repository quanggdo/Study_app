import 'package:isar/isar.dart';

import '../../models/flashcard_card.dart';
import '../../models/flashcard_deck.dart';
import '../../models/due_card.dart';
import '../../models/review_state.dart';
import 'flashcard_card_entity.dart';
import 'flashcard_deck_entity.dart';
import 'review_state_entity.dart';

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

  Future<ReviewState?> getReviewState({required String cardId}) async {
    final entity = await _isar.reviewStateEntitys
        .where()
        .cardIdEqualTo(cardId)
        .findFirst();

    if (entity == null || entity.isDeleted) return null;

    return ReviewState(
      cardId: entity.cardId,
      deckId: entity.deckId,
      uId: entity.uId,
      dueAt: entity.dueAt,
      reps: entity.reps,
      lapses: entity.lapses,
      intervalDays: entity.intervalDays,
      easeFactor: entity.easeFactor,
      lastReviewedAt: entity.lastReviewedAt,
      updatedAt: entity.updatedAt,
      isDeleted: entity.isDeleted,
    );
  }

  Future<ReviewState> getOrCreateReviewState({
    required String uId,
    required String deckId,
    required String cardId,
    DateTime? now,
  }) async {
    final existing = await getReviewState(cardId: cardId);
    if (existing != null) return existing;

    final t = now ?? DateTime.now();
    final created = ReviewState(
      cardId: cardId,
      deckId: deckId,
      uId: uId,
      dueAt: t,
      updatedAt: t,
    );

    await upsertReviewState(created);
    return created;
  }

  Future<void> upsertReviewState(ReviewState state) async {
    await _isar.writeTxn(() async {
      final entity = ReviewStateEntity(
        cardId: state.cardId,
        deckId: state.deckId,
        uId: state.uId,
        dueAt: state.dueAt,
        reps: state.reps,
        lapses: state.lapses,
        intervalDays: state.intervalDays,
        easeFactor: state.easeFactor,
        lastReviewedAt: state.lastReviewedAt,
        updatedAt: state.updatedAt,
        isDeleted: state.isDeleted,
      );

      await _isar.reviewStateEntitys.putByCardId(entity);

      // best-effort: cập nhật lastStudiedAt cho deck
      final deck = await _isar.flashcardDeckEntitys
          .where()
          .idEqualTo(state.deckId)
          .findFirst();
      if (deck != null) {
        final t = DateTime.now();
        deck.lastStudiedAt = t;
        deck.updatedAt = t;
        await _isar.flashcardDeckEntitys.put(deck);
      }
    });
  }

  Future<List<DueCard>> getDueCards({
    required String uId,
    required String deckId,
    required DateTime now,
    int limit = 20,
  }) async {
    final cards = await _isar.flashcardCardEntitys
        .where()
        .deckIdEqualTo(deckId)
        .filter()
        .uIdEqualTo(uId)
        .isDeletedEqualTo(false)
        .findAll();

    if (cards.isEmpty) return const [];

    final states = await _isar.reviewStateEntitys
        .where()
        .deckIdEqualTo(deckId)
        .filter()
        .uIdEqualTo(uId)
        .isDeletedEqualTo(false)
        .findAll();

    final byCardId = <String, ReviewStateEntity>{
      for (final s in states) s.cardId: s,
    };

    final result = <DueCard>[];
    for (final c in cards) {
      final s = byCardId[c.id];

      ReviewState? state;
      if (s != null) {
        state = ReviewState(
          cardId: s.cardId,
          deckId: s.deckId,
          uId: s.uId,
          dueAt: s.dueAt,
          reps: s.reps,
          lapses: s.lapses,
          intervalDays: s.intervalDays,
          easeFactor: s.easeFactor,
          lastReviewedAt: s.lastReviewedAt,
          updatedAt: s.updatedAt,
          isDeleted: s.isDeleted,
        );
      }

      final isDue = state == null || !state.dueAt.isAfter(now);
      if (!isDue) continue;

      result.add(
        DueCard(
          card: FlashcardCard(
            id: c.id,
            deckId: c.deckId,
            uId: c.uId,
            front: c.front,
            back: c.back,
            hint: c.hint,
            createdAt: c.createdAt,
            updatedAt: c.updatedAt,
            isDeleted: c.isDeleted,
          ),
          state: state,
        ),
      );

      if (result.length >= limit) break;
    }

    return result;
  }
}
