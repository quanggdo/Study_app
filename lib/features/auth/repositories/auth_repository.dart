import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/firestore_constants.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/services/firebase_firestore_service.dart';
import '../../../core/services/firebase_storage_service.dart';
import '../models/user_model.dart';

// =============================================================================
// Providers
// =============================================================================

/// Provider for [FirebaseAuthService].
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

/// Provider for [FirebaseFirestoreService].
final firebaseFirestoreServiceProvider =
    Provider<FirebaseFirestoreService>((ref) {
  return FirebaseFirestoreService();
});

/// Provider for [FirebaseStorageService].
final firebaseStorageServiceProvider =
    Provider<FirebaseStorageService>((ref) {
  return FirebaseStorageService();
});

/// Provider for [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    authService: ref.watch(firebaseAuthServiceProvider),
    firestoreService: ref.watch(firebaseFirestoreServiceProvider),
    storageService: ref.watch(firebaseStorageServiceProvider),
  );
});

// =============================================================================
// AuthRepository
// =============================================================================

/// Repository layer for authentication and user profile management.
///
/// All external Firebase calls are delegated to the appropriate service:
/// - [FirebaseAuthService]    – Authentication operations.
/// - [FirebaseFirestoreService] – User profile storage.
/// - [FirebaseStorageService] – Profile photo upload/deletion.
class AuthRepository {
  final FirebaseAuthService _authService;
  final FirebaseFirestoreService _firestoreService;
  final FirebaseStorageService _storageService;

  AuthRepository({
    required FirebaseAuthService authService,
    required FirebaseFirestoreService firestoreService,
    required FirebaseStorageService storageService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        _storageService = storageService;

  // ---------------------------------------------------------------------------
  // Auth State
  // ---------------------------------------------------------------------------

  /// The currently signed-in Firebase [User], or null.
  User? get currentUser => _authService.currentUser;

  /// A stream that emits user auth-state changes.
  Stream<User?> authStateChanges() => _authService.authStateChanges;

  // ---------------------------------------------------------------------------
  // Sign In / Register
  // ---------------------------------------------------------------------------

  /// Signs in with email and password.
  Future<UserCredential> signInWithEmail(
      String email, String password) async {
    return await _authService.signInWithEmailAndPassword(email, password);
  }

  /// Creates a new account, sets a display name, and bootstraps the user profile.
  Future<UserCredential> registerWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    final credential = await _authService.createUserWithEmailAndPassword(
      email,
      password,
    );

    await _authService.updateDisplayName(displayName);

    final userModel = UserModel(
      uid: credential.user!.uid,
      email: email.trim(),
      displayName: displayName,
      createdAt: DateTime.now(),
    );
    await createUserProfile(userModel);

    return credential;
  }

  // ---------------------------------------------------------------------------
  // Password Management
  // ---------------------------------------------------------------------------

  /// Sends a password-reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  /// Verifies [currentPassword], then sets [newPassword].
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    await _authService.reauthenticateAndChangePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  // ---------------------------------------------------------------------------
  // Sign Out
  // ---------------------------------------------------------------------------

  Future<void> signOut() async {
    await _authService.signOut();
  }

  // ---------------------------------------------------------------------------
  // User Profile – Firestore
  // ---------------------------------------------------------------------------

  /// Fetches the user profile document for the given [uid].
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestoreService.getDocument(
      FirestoreConstants.users,
      uid,
    );
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Creates (or overwrites) a user profile document.
  Future<void> createUserProfile(UserModel user) async {
    await _firestoreService.setDocument(
      FirestoreConstants.users,
      user.uid,
      user.toFirestore(),
    );
  }

  /// Partially updates a user profile document and syncs display name / photo
  /// with Firebase Auth.
  Future<void> updateUserProfile(UserModel user) async {
    await _firestoreService.updateDocument(
      FirestoreConstants.users,
      user.uid,
      user.toFirestore(),
    );

    await _authService.updateDisplayName(user.displayName);
    if (user.photoUrl != null) {
      await _authService.updatePhotoURL(user.photoUrl!);
    }
  }

  // ---------------------------------------------------------------------------
  // Profile Photo – Storage
  // ---------------------------------------------------------------------------

  /// Uploads a profile photo for [uid], optionally removing the old one.
  /// Returns the public download URL.
  Future<String> uploadProfilePhoto(
    String uid,
    Uint8List imageBytes, {
    String? oldPhotoUrl,
  }) async {
    return await _storageService.uploadProfilePhoto(
      uid,
      imageBytes,
      oldPhotoUrl: oldPhotoUrl,
    );
  }
}