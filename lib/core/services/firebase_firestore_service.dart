import 'package:cloud_firestore/cloud_firestore.dart';

/// Service wrapper for Cloud Firestore operations.
/// Centralizes all Firestore access, making it easy to swap out
/// or mock during testing.
class FirebaseFirestoreService {
  final FirebaseFirestore _firestore;

  FirebaseFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // Document Operations
  // ---------------------------------------------------------------------------

  /// Fetches a single document by collection path and document ID.
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
    String collection,
    String docId,
  ) async {
    return await _firestore.collection(collection).doc(docId).get();
  }

  /// Creates or overwrites a document at the given path.
  Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    await _firestore
        .collection(collection)
        .doc(docId)
        .set(data, SetOptions(merge: merge));
  }

  /// Partially updates fields of an existing document.
  Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }

  /// Deletes a document by collection and document ID.
  Future<void> deleteDocument(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  // ---------------------------------------------------------------------------
  // Collection Operations
  // ---------------------------------------------------------------------------

  /// Returns a real-time stream of all documents in a collection,
  /// optionally filtered by a single field equality check.
  Stream<QuerySnapshot<Map<String, dynamic>>> collectionStream(
    String collection, {
    String? whereField,
    Object? whereValue,
    String? orderByField,
    bool descending = false,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query =
        _firestore.collection(collection);

    if (whereField != null && whereValue != null) {
      query = query.where(whereField, isEqualTo: whereValue);
    }
    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }

  /// Fetches all documents in a collection as a one-time read,
  /// optionally filtered by a single field equality check.
  Future<QuerySnapshot<Map<String, dynamic>>> getCollection(
    String collection, {
    String? whereField,
    Object? whereValue,
    String? orderByField,
    bool descending = false,
  }) async {
    Query<Map<String, dynamic>> query =
        _firestore.collection(collection);

    if (whereField != null && whereValue != null) {
      query = query.where(whereField, isEqualTo: whereValue);
    }
    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }

    return await query.get();
  }

  // ---------------------------------------------------------------------------
  // Batch / Transaction helpers (future-proof)
  // ---------------------------------------------------------------------------

  /// Provides the underlying [FirebaseFirestore] instance for advanced
  /// use-cases such as batch writes or transactions.
  FirebaseFirestore get instance => _firestore;
}
