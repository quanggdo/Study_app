import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/isar_service.dart';
import '../data/local/isar_flashcard_local_datasource.dart';
import '../models/flashcard_card.dart';
import '../models/flashcard_deck.dart';
import 'flashcard_repository_contract.dart';

class IsarFlashcardRepository implements FlashcardRepository {
  IsarFlashcardRepository({required IsarFlashcardLocalDatasource local})
      : _local = local;

  final IsarFlashcardLocalDatasource _local;

  @override
  Stream<List<FlashcardDeck>> watchDecks({required String uId}) {
    return _local.watchDecks(uId: uId);
  }

  @override
  Stream<List<FlashcardCard>> watchCards({
    required String uId,
    required String deckId,
  }) {
    return _local.watchCards(uId: uId, deckId: deckId);
  }

  @override
  Future<FlashcardDeck> createDeck({
    required String uId,
    required String title,
    String? description,
  }) async {
    final now = DateTime.now();
    final deck = FlashcardDeck(
      id: const Uuid().v4(),
      uId: uId,
      title: title.trim(),
      description: description?.trim().isEmpty == true ? null : description,
      createdAt: now,
      updatedAt: now,
    );

    await _local.upsertDeck(deck);
    return deck;
  }

  @override
  Future<FlashcardCard> createCard({
    required String uId,
    required String deckId,
    required String front,
    required String back,
    String? hint,
  }) async {
    final now = DateTime.now();
    final card = FlashcardCard(
      id: const Uuid().v4(),
      deckId: deckId,
      uId: uId,
      front: front.trim(),
      back: back.trim(),
      hint: hint?.trim().isEmpty == true ? null : hint,
      createdAt: now,
      updatedAt: now,
    );

    await _local.upsertCard(card);
    return card;
  }
}

final flashcardRepositoryProvider = Provider<FlashcardRepository>((ref) {
  final isar = ref.watch(isarServiceProvider).isar;
  final local = IsarFlashcardLocalDatasource(isar);
  return IsarFlashcardRepository(local: local);
});
