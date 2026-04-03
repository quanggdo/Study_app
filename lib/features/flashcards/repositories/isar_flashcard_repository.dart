import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/isar_service.dart';
import '../../../features/auth/repositories/auth_repository.dart';
import '../data/local/flashcard_isar_local.dart';
import '../models/flashcard_card.dart';
import '../models/flashcard_deck.dart';
import '../models/due_card.dart';
import '../models/review_state.dart';
import 'flashcard_repository_contract.dart';
import 'in_memory_flashcard_repository.dart';
import 'firestore_flashcard_repository.dart';

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

  @override
  Future<void> updateCard({
    required String uId,
    required FlashcardCard card,
  }) async {
    if (uId != card.uId) return;
    final updated = card.copyWith(updatedAt: DateTime.now());
    await _local.upsertCard(updated);
  }

  @override
  Future<void> deleteCard({
    required String uId,
    required FlashcardCard card,
  }) async {
    if (uId != card.uId) return;
    final deleted = card.copyWith(
      isDeleted: true,
      updatedAt: DateTime.now(),
    );
    await _local.upsertCard(deleted);
  }

  @override
  Future<List<DueCard>> getDueCards({
    required String uId,
    required String deckId,
    required DateTime now,
    int limit = 100,
  }) {
    return _local.getDueCards(
      uId: uId,
      deckId: deckId,
      now: now,
      limit: limit,
    );
  }

  @override
  Future<ReviewState> getOrCreateReviewState({
    required String uId,
    required String deckId,
    required String cardId,
    DateTime? now,
  }) {
    return _local.getOrCreateReviewState(
      uId: uId,
      deckId: deckId,
      cardId: cardId,
      now: now,
    );
  }

  @override
  Future<void> upsertReviewState(ReviewState state) {
    return _local.upsertReviewState(state);
  }
}

final flashcardRepositoryProvider = Provider<FlashcardRepository>((ref) {
  // Ưu tiên Firestore (sync đa thiết bị). cloud_firestore hỗ trợ cả mobile & web.
  final firestoreService = ref.watch(firebaseFirestoreServiceProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  final currentUser = authRepo.currentUser;

  if (currentUser != null) {
    return FirestoreFlashcardRepository(firestoreService: firestoreService);
  }

  // Nếu chưa đăng nhập thì fallback để tránh crash.
  if (kIsWeb) return InMemoryFlashcardRepository();

  final isar = ref.watch(isarServiceProvider).isar;
  final local = IsarFlashcardLocalDatasource(isar);
  return IsarFlashcardRepository(local: local);
});
