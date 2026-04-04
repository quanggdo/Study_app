import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firebase_firestore_service.dart';
import '../models/due_card.dart';
import '../models/flashcard_card.dart';
import '../models/flashcard_deck.dart';
import '../models/review_state.dart';
import 'flashcard_repository_contract.dart';

/// Firestore implementation.
///
/// Schema (read-only, root collection):
/// - flashcards/{deckId}
///   fields: title, category, author, description, cards[] {id, front/back or forehead/back}, createdAt
///
/// Ghi chú:
/// - Dùng soft-delete (isDeleted=true) để dễ sync.
/// - Hiện tại getDueCards join in-memory (đơn giản, dễ đúng) -> có thể tối ưu sau.
class FirestoreFlashcardRepository implements FlashcardRepository {
  FirestoreFlashcardRepository({required FirebaseFirestoreService firestoreService})
      : _firestore = firestoreService;

  final FirebaseFirestoreService _firestore;

  FirebaseFirestore get _db => _firestore.instance;

  CollectionReference<Map<String, dynamic>> _decksCol() => _db.collection('flashcards');

  CollectionReference<Map<String, dynamic>> _statesCol(String uId) =>
      _db.collection('users').doc(uId).collection('flashcard_states');

  String _stateDocId({required String deckId, required String cardId}) => '${deckId}_$cardId';

  FlashcardDeck _deckFromRootDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final raw = doc.data() ?? <String, dynamic>{};
    final json = _decodeDateTimes(raw);

    return FlashcardDeck.fromJson(<String, Object?>{
      ...json,
      'id': doc.id,
      // Read-only public decks -> gán uId rỗng để tương thích model hiện tại.
      'uId': (raw['uId'] as String?) ?? '',
      'title': (raw['title'] as String?) ?? '',
      'description': raw['description'],
      'tags': raw['tags'] ?? const <String>[],
      'cardCount': (raw['cards'] is List) ? (raw['cards'] as List).length : (raw['cardCount'] ?? 0),
      'lastStudiedAt': json['lastStudiedAt'],
      'createdAt': json['createdAt'] ?? DateTime.now().toIso8601String(),
      'updatedAt': json['updatedAt'] ?? json['createdAt'] ?? DateTime.now().toIso8601String(),
      'isDeleted': raw['isDeleted'] ?? false,
    });
  }

  List<FlashcardCard> _cardsFromDeckDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final raw = doc.data() ?? <String, dynamic>{};
    final deckId = doc.id;
    final cardsRaw = raw['cards'];
    if (cardsRaw is! List) return const <FlashcardCard>[];

    final nowIso = DateTime.now().toIso8601String();

    return cardsRaw.asMap().entries.map((entry) {
      final index = entry.key;
      final dynamic item = entry.value;
      final m = (item is Map)
          ? item.map((k, v) => MapEntry(k.toString(), v))
          : const <String, dynamic>{};

      // ID phải ổn định theo dữ liệu gốc để trạng thái due không bị mất.
      final rawId = (m['id'] ?? m['card_id'] ?? m['cardId'] ?? '').toString().trim();
      final id = rawId.isNotEmpty ? rawId : '${deckId}_$index';

      final rawFront = (
        m['front'] ??
        m['forehead'] ??
        m['question'] ??
        m['term'] ??
        m['title'] ??
        ''
      ).toString().trim();

      final rawBack = (
        m['back'] ??
        m['answer'] ??
        m['definition'] ??
        m['content'] ??
        m['explanation'] ??
        ''
      ).toString().trim();

      final front = rawFront.isNotEmpty ? rawFront : 'Thẻ ${index + 1}';
      final back = rawBack.isNotEmpty ? rawBack : '(Chưa có nội dung)';
      final hint = (m['hint'] ?? m['note'])?.toString();

      return FlashcardCard.fromJson(<String, Object?>{
        'id': id,
        'deckId': deckId,
        // Read-only public deck -> uId rỗng
        'uId': (raw['uId'] as String?) ?? '',
        'front': front,
        'back': back,
        'hint': hint,
        'createdAt': nowIso,
        'updatedAt': nowIso,
        'isDeleted': false,
      });
    }).toList();
  }

  ReviewState _stateFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String uId,
    required String deckId,
    required String cardId,
  }) {
    final raw = doc.data() ?? <String, dynamic>{};
    final json = _decodeDateTimes(raw);

    return ReviewState.fromJson(<String, Object?>{
      ...json,
      'uId': uId,
      'deckId': deckId,
      'cardId': cardId,
      'dueAt': json['dueAt'] ?? DateTime.now().toIso8601String(),
      'updatedAt': json['updatedAt'] ?? DateTime.now().toIso8601String(),
      'reps': raw['reps'] ?? 0,
      'lapses': raw['lapses'] ?? 0,
      'intervalDays': raw['intervalDays'] ?? 0,
      'intervalMinutes': raw['intervalMinutes'] ?? 0,
      'stateType': raw['stateType'] ?? 'learning',
      'easeFactor': raw['easeFactor'] ?? 2.5,
      'lastReviewedAt': json['lastReviewedAt'],
      'isDeleted': raw['isDeleted'] ?? false,
    });
  }

  Map<String, dynamic> _normalizeDateTimes(Map<String, dynamic> json) {
    final out = <String, dynamic>{};
    for (final e in json.entries) {
      final v = e.value;
      if (v is DateTime) {
        out[e.key] = Timestamp.fromDate(v);
        continue;
      }
      if (v is String) {
        final parsed = DateTime.tryParse(v);
        if (parsed != null) {
          out[e.key] = Timestamp.fromDate(parsed);
          continue;
        }
      }
      out[e.key] = v;
    }
    return out;
  }

  Map<String, Object?> _decodeDateTimes(Map<String, dynamic> json) {
    final out = <String, Object?>{};
    for (final e in json.entries) {
      final v = e.value;
      if (v is Timestamp) {
        out[e.key] = v.toDate().toIso8601String();
      } else {
        out[e.key] = v;
      }
    }
    return out;
  }

  @override
  Stream<List<FlashcardDeck>> watchDecks({required String uId}) {
    // Read-only: ignore uId filter, chỉ yêu cầu user đã đăng nhập ở rules.
    return _decksCol().snapshots().map((snap) {
      final decks = snap.docs
          .map(_deckFromRootDoc)
          .where((d) => !d.isDeleted && d.title.trim().isNotEmpty)
          .toList();
      decks.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return decks;
    });
  }

  @override
  Stream<List<FlashcardCard>> watchCards({
    required String uId,
    required String deckId,
  }) {
    // Read-only: cards[] nằm trong doc deck
    return _decksCol().doc(deckId).snapshots().map((doc) {
      if (!doc.exists) return const <FlashcardCard>[];
      return _cardsFromDeckDoc(doc);
    });
  }

  @override
  Future<FlashcardDeck> createDeck({
    required String uId,
    required String title,
    String? description,
  }) {
    throw UnsupportedError('Flashcards is read-only (data from Firestore preset).');
  }

  @override
  Future<FlashcardCard> createCard({
    required String uId,
    required String deckId,
    required String front,
    required String back,
    String? hint,
  }) {
    throw UnsupportedError('Flashcards is read-only (data from Firestore preset).');
  }

  @override
  Future<void> updateCard({required String uId, required FlashcardCard card}) {
    throw UnsupportedError('Flashcards is read-only (data from Firestore preset).');
  }

  @override
  Future<void> deleteCard({required String uId, required FlashcardCard card}) {
    throw UnsupportedError('Flashcards is read-only (data from Firestore preset).');
  }

  @override
  Future<List<DueCard>> getDueCards({
    required String uId,
    required String deckId,
    required DateTime now,
    int limit = 100,
  }) async {
    // 1) Lấy deck + danh sách cards
    final deckDoc = await _decksCol().doc(deckId).get();
    if (!deckDoc.exists) return const <DueCard>[];

    final cards = _cardsFromDeckDoc(deckDoc);
    if (cards.isEmpty) return const <DueCard>[];

    // 2) Lấy states của user cho deck này (flat collection -> filter by deckId)
    final statesSnap = await _statesCol(uId).where('deckId', isEqualTo: deckId).get();
    final stateByCardId = <String, ReviewState>{};
    for (final d in statesSnap.docs) {
      final data = d.data();
      final cardId = (data['cardId'] as String?);
      if (cardId == null) continue;
      try {
        stateByCardId[cardId] = _stateFromDoc(d, uId: uId, deckId: deckId, cardId: cardId);
      } catch (_) {
        // ignore bad doc
      }
    }

    // 3) Xác định thẻ đến hạn
    final due = <DueCard>[];
    for (final c in cards) {
      final s = stateByCardId[c.id];

      // Chưa có state => coi như due
      if (s == null) {
        due.add(DueCard(card: c, state: null));
        continue;
      }

      // Soft delete thì bỏ qua
      if (s.isDeleted) continue;

      if (!s.dueAt.isAfter(now)) {
        due.add(DueCard(card: c, state: s));
      }
    }

    // 4) Sắp xếp: thẻ chưa ôn lên trước, sau đó theo dueAt tăng dần
    due.sort((a, b) {
      final ad = a.state?.dueAt;
      final bd = b.state?.dueAt;
      if (ad == null && bd == null) return 0;
      if (ad == null) return -1;
      if (bd == null) return 1;
      return ad.compareTo(bd);
    });

    if (due.length <= limit) return due;
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

    final docId = _stateDocId(deckId: deckId, cardId: cardId);
    final ref = _statesCol(uId).doc(docId);
    final snap = await ref.get();

    if (snap.exists) {
      return _stateFromDoc(snap, uId: uId, deckId: deckId, cardId: cardId);
    }

    final state = ReviewState(
      uId: uId,
      deckId: deckId,
      cardId: cardId,
      dueAt: now,
      reps: 0,
      lapses: 0,
      intervalDays: 0,
      intervalMinutes: 0,
      stateType: ReviewStateType.learning,
      easeFactor: 2.5,
      lastReviewedAt: null,
      updatedAt: now,
      isDeleted: false,
    );

    await ref.set(_normalizeDateTimes(state.toJson()));
    return state;
  }

  @override
  Future<void> upsertReviewState(ReviewState state) async {
    final docId = _stateDocId(deckId: state.deckId, cardId: state.cardId);
    final ref = _statesCol(state.uId).doc(docId);
    await ref.set(_normalizeDateTimes(state.toJson()), SetOptions(merge: true));
  }
}
