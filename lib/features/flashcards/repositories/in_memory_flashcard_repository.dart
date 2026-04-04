import 'dart:async';

import 'package:uuid/uuid.dart';

import '../models/due_card.dart';
import '../models/flashcard_card.dart';
import '../models/flashcard_deck.dart';
import '../models/review_state.dart';
import 'flashcard_repository_contract.dart';

/// Repository fallback cho Web (Chrome) để UI Flashcards chạy được.
///
/// - Không persist: dữ liệu chỉ sống trong runtime.
/// - Mục đích: tránh crash do Isar/path_provider không support Web.
class InMemoryFlashcardRepository implements FlashcardRepository {
  final _decksByUser = <String, List<FlashcardDeck>>{};
  final _cardsByDeck = <String, List<FlashcardCard>>{};
  final _states = <String, ReviewState>{};

  final _decksCtr = StreamController<List<FlashcardDeck>>.broadcast();
  final _cardsCtrByDeck = <String, StreamController<List<FlashcardCard>>>{};

  StreamController<List<FlashcardCard>> _cardsCtr(String deckId) {
    return _cardsCtrByDeck.putIfAbsent(
      deckId,
      () => StreamController<List<FlashcardCard>>.broadcast(),
    );
  }

  void _emitDecks(String uId) {
    _decksCtr.add(List.unmodifiable(_decksByUser[uId] ?? const []));
  }

  void _emitCards(String deckId) {
    _cardsCtr(deckId).add(List.unmodifiable(_cardsByDeck[deckId] ?? const []));
  }

  @override
  Stream<List<FlashcardDeck>> watchDecks({required String uId}) {
    Future.microtask(() => _emitDecks(uId));
    return _decksCtr.stream;
  }

  @override
  Stream<List<FlashcardCard>> watchCards({
    required String uId,
    required String deckId,
  }) {
    Future.microtask(() => _emitCards(deckId));
    return _cardsCtr(deckId).stream;
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

    final next = List<FlashcardDeck>.from(_decksByUser[uId] ?? const [])..add(deck);
    _decksByUser[uId] = next;
    _emitDecks(uId);
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

    final next = List<FlashcardCard>.from(_cardsByDeck[deckId] ?? const [])..add(card);
    _cardsByDeck[deckId] = next;
    _emitCards(deckId);
    _emitDecks(uId);
    return card;
  }

  @override
  Future<void> updateCard({required String uId, required FlashcardCard card}) async {
    if (uId != card.uId) return;

    final list = List<FlashcardCard>.from(_cardsByDeck[card.deckId] ?? const []);
    final idx = list.indexWhere((c) => c.id == card.id);
    if (idx == -1) return;

    list[idx] = card.copyWith(updatedAt: DateTime.now());
    _cardsByDeck[card.deckId] = list;
    _emitCards(card.deckId);
  }

  @override
  Future<void> deleteCard({required String uId, required FlashcardCard card}) async {
    if (uId != card.uId) return;

    final list = List<FlashcardCard>.from(_cardsByDeck[card.deckId] ?? const []);
    final idx = list.indexWhere((c) => c.id == card.id);
    if (idx == -1) return;

    list[idx] = card.copyWith(
      isDeleted: true,
      updatedAt: DateTime.now(),
    );
    _cardsByDeck[card.deckId] = list;
    _emitCards(card.deckId);
  }

  String _key(String uId, String deckId, String cardId) => '$uId|$deckId|$cardId';

  @override
  Future<List<DueCard>> getDueCards({
    required String uId,
    required String deckId,
    required DateTime now,
    int limit = 100,
  }) async {
    final cards = (_cardsByDeck[deckId] ?? const []).where((c) => !c.isDeleted);

    final due = <DueCard>[];
    for (final c in cards) {
      final s = _states[_key(uId, deckId, c.id)];
      final dueAt = s?.dueAt;
      final isDue = dueAt == null || !dueAt.isAfter(now);
      if (isDue) {
        due.add(DueCard(card: c, state: s));
      }
    }

    // Sort: card mới (state==null) lên trước, sau đó theo dueAt tăng dần
    due.sort((a, b) {
      final ad = a.state?.dueAt;
      final bd = b.state?.dueAt;
      if (ad == null && bd == null) return 0;
      if (ad == null) return -1;
      if (bd == null) return 1;
      return ad.compareTo(bd);
    });

    return due.take(limit).toList();
  }

  @override
  Future<ReviewState> getOrCreateReviewState({
    required String uId,
    required String deckId,
    required String cardId,
    DateTime? now,
  }) async {
    now ??= DateTime.now();
    final k = _key(uId, deckId, cardId);

    return _states.putIfAbsent(
      k,
      () => ReviewState(
        uId: uId,
        deckId: deckId,
        cardId: cardId,
        dueAt: now!,
        reps: 0,
        lapses: 0,
        intervalDays: 0,
        easeFactor: 2.5,
        lastReviewedAt: null,
        updatedAt: now!,
        isDeleted: false,
      ),
    );
  }

  @override
  Future<void> upsertReviewState(ReviewState state) async {
    _states[_key(state.uId, state.deckId, state.cardId)] = state;
  }
}
