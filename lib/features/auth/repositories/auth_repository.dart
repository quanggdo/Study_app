import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/firestore_constants.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/services/firebase_firestore_service.dart';
import '../../../core/services/firebase_storage_service.dart';
import '../models/user_model.dart';


final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

final firebaseFirestoreServiceProvider =
    Provider<FirebaseFirestoreService>((ref) {
  return FirebaseFirestoreService();
});

final firebaseStorageServiceProvider =
    Provider<FirebaseStorageService>((ref) {
  return FirebaseStorageService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    authService: ref.watch(firebaseAuthServiceProvider),
    firestoreService: ref.watch(firebaseFirestoreServiceProvider),
    storageService: ref.watch(firebaseStorageServiceProvider),
  );
});

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

  User? get currentUser => _authService.currentUser;

  Stream<User?> authStateChanges() => _authService.authStateChanges;

  Future<UserCredential> signInWithEmail(
      String email, String password) async {
    return await _authService.signInWithEmailAndPassword(email, password);
  }

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

  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    await _authService.reauthenticateAndChangePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }


  Future<void> signOut() async {
    await _authService.signOut();
  }

  
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestoreService.getDocument(
      FirestoreConstants.users,
      uid,
    );
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> createUserProfile(UserModel user) async {
    await _firestoreService.setDocument(
      FirestoreConstants.users,
      user.uid,
      user.toFirestore(),
    );
  }

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