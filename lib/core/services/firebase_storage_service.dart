import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// Service wrapper for Firebase Storage operations.
/// Handles file uploads, downloads, and deletions.
class FirebaseStorageService {
  final FirebaseStorage _storage;

  FirebaseStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  // ---------------------------------------------------------------------------
  // Upload
  // ---------------------------------------------------------------------------

  /// Uploads raw bytes to the given [storagePath] and returns the download URL.
  ///
  /// [contentType] defaults to `application/octet-stream` if not specified.
  Future<String> uploadBytes(
    String storagePath,
    Uint8List bytes, {
    String contentType = 'application/octet-stream',
  }) async {
    final ref = _storage.ref().child(storagePath);
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    return await ref.getDownloadURL();
  }

  // ---------------------------------------------------------------------------
  // Profile Photo – Convenience Method
  // ---------------------------------------------------------------------------

  /// Uploads a new profile photo for [uid], optionally deleting the
  /// [oldPhotoUrl] first. Returns the download URL of the new photo.
  Future<String> uploadProfilePhoto(
    String uid,
    Uint8List imageBytes, {
    String? oldPhotoUrl,
  }) async {
    // Delete old photo if it exists and is in our Storage bucket
    if (oldPhotoUrl != null && oldPhotoUrl.isNotEmpty) {
      await deleteByUrl(oldPhotoUrl);
    }

    return await uploadBytes(
      'profile_photos/$uid.jpg',
      imageBytes,
      contentType: 'image/jpeg',
    );
  }

  // ---------------------------------------------------------------------------
  // Download
  // ---------------------------------------------------------------------------

  /// Retrieves the public download URL for a file at [storagePath].
  Future<String> getDownloadUrl(String storagePath) async {
    return await _storage.ref().child(storagePath).getDownloadURL();
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  /// Deletes a file using its full Firebase Storage [url].
  /// Silently ignores errors (e.g. file already deleted or external URL).
  Future<void> deleteByUrl(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {
      // Intentionally ignored – file may not exist or URL may be external
    }
  }

  /// Deletes a file by its [storagePath] relative to the bucket root.
  Future<void> deleteByPath(String storagePath) async {
    try {
      await _storage.ref().child(storagePath).delete();
    } catch (_) {
      // Intentionally ignored
    }
  }
}
