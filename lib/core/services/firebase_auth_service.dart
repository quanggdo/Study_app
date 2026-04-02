import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

/// Service wrapper for Firebase Authentication operations.
/// Also owns app-level Firebase initialization.
class FirebaseAuthService {
  final FirebaseAuth _auth;

  FirebaseAuthService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  // ---------------------------------------------------------------------------
  // App Initialization
  // ---------------------------------------------------------------------------

  /// Initializes the Firebase app. Call once in main() before runApp().
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      // Already initialized – safe to ignore
      if (e is! FirebaseException || e.code != 'duplicate-app') {
        rethrow;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  /// Currently signed-in user, or null if not authenticated.
  User? get currentUser => _auth.currentUser;

  /// Stream that emits auth state changes (sign-in / sign-out events).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ---------------------------------------------------------------------------
  // Sign In / Sign Up
  // ---------------------------------------------------------------------------

  /// Signs in with email and password.
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Creates a new user account with email and password.
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ---------------------------------------------------------------------------
  // Profile Updates
  // ---------------------------------------------------------------------------

  /// Updates the display name of the currently signed-in user.
  Future<void> updateDisplayName(String displayName) async {
    await _auth.currentUser?.updateDisplayName(displayName);
  }

  /// Updates the photo URL of the currently signed-in user.
  Future<void> updatePhotoURL(String photoURL) async {
    await _auth.currentUser?.updatePhotoURL(photoURL);
  }

  // ---------------------------------------------------------------------------
  // Password Management
  // ---------------------------------------------------------------------------

  /// Sends a password reset email to the given address.
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Re-authenticates the current user and then updates the password.
  ///
  /// Throws [FirebaseAuthException] if re-authentication fails.
  Future<void> reauthenticateAndChangePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Không có người dùng nào đang đăng nhập.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  // ---------------------------------------------------------------------------
  // Sign Out
  // ---------------------------------------------------------------------------

  /// Signs the current user out.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

// Provider-friendly singleton getter – features will access via Riverpod
FirebaseAuthService get firebaseAuthServiceInstance => FirebaseAuthService();
