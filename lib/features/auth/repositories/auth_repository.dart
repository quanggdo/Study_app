import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/firestore_constants.dart';
import '../models/user_model.dart';


final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
  );
});

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final FirebaseFirestore _firestore;
 
  AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    FirebaseStorage? storage,
  })  : _auth = auth,
        _firestore = firestore,
        _storage = storage ?? FirebaseStorage.instance;

 
  User? get currentUser => _auth.currentUser;
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> registerWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await credential.user?.updateDisplayName(displayName);

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
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('Không có người dùng nào đang đăng nhập');
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore
        .collection(FirestoreConstants.users)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> createUserProfile(UserModel user) async {
    await _firestore
        .collection(FirestoreConstants.users)
        .doc(user.uid)
        .set(user.toFirestore());
  }

  Future<void> updateUserProfile(UserModel user) async {
    await _firestore
        .collection(FirestoreConstants.users)
        .doc(user.uid)
        .update(user.toFirestore());

    await _auth.currentUser?.updateDisplayName(user.displayName);
    if (user.photoUrl != null) {
      await _auth.currentUser?.updatePhotoURL(user.photoUrl);
    }
  }


  Future<String> uploadProfilePhoto(
    String uid,
    Uint8List imageBytes, {
    String? oldPhotoUrl,
  }) async {
    // Delete old photo from Storage if it exists
    if (oldPhotoUrl != null && oldPhotoUrl.isNotEmpty) {
      try {
        final oldRef = _storage.refFromURL(oldPhotoUrl);
        await oldRef.delete();
      } catch (_) {
        // Ignore errors (file might not exist or URL is external)
      }
    }

    // Upload new photo
    final storageRef = _storage.ref().child('profile_photos/$uid.jpg');
    await storageRef.putData(
      imageBytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await storageRef.getDownloadURL();
  }
}