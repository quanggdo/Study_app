import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_academic_assistant/features/auth/models/user_model.dart';
import 'package:student_academic_assistant/features/auth/repositories/auth_repository.dart';
import 'package:student_academic_assistant/features/dashboard/viewmodels/stats_viewmodel.dart';

// =============================================================================
// Auth Status
// =============================================================================
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

// =============================================================================
// Auth State
// =============================================================================
class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

// =============================================================================
// Auth Notifier (ViewModel)
// =============================================================================
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier(this._repository, this._ref) : super(const AuthState()) {
    _initialize();
  }

  void _initialize() {
    // Resolve initial state synchronously from cached user
    final currentUser = _repository.currentUser;
    if (currentUser != null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: UserModel.fromFirebaseUser(currentUser),
      );
      _loadProfile(currentUser.uid);
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }

    // Listen for subsequent auth changes
    _repository.authStateChanges().listen((user) async {
      if (user != null) {
        final profile = await _repository.getUserProfile(user.uid);
        state = AuthState(
          status: AuthStatus.authenticated,
          user: profile ?? UserModel.fromFirebaseUser(user),
        );
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
  }

  Future<void> _loadProfile(String uid) async {
    try {
      final profile = await _repository.getUserProfile(uid);
      if (profile != null && mounted) {
        state = state.copyWith(user: profile);
      }
    } catch (e) {
      debugPrint('Failed to load user profile: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------
  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _repository.signInWithEmail(email, password);
    } on FirebaseAuthException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: _mapFirebaseError(e.code),
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: 'Đã xảy ra lỗi. Vui lòng thử lại.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Register
  // ---------------------------------------------------------------------------
  Future<void> register(
      String email, String password, String displayName) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _repository.registerWithEmail(email, password, displayName);
    } on FirebaseAuthException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: _mapFirebaseError(e.code),
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: 'Đã xảy ra lỗi. Vui lòng thử lại.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Update Profile
  // ---------------------------------------------------------------------------
  Future<bool> updateProfile({
    String? displayName,
    int? targetStudyTime,
    Uint8List? photoBytes,
  }) async {
    try {
      if (state.user == null) return false;

      var updatedUser = state.user!;

      // Upload photo if provided
      if (photoBytes != null) {
        final photoUrl = await _repository.uploadProfilePhoto(
          updatedUser.uid,
          photoBytes,
          oldPhotoUrl: updatedUser.photoUrl,
        );
        updatedUser = updatedUser.copyWith(photoUrl: photoUrl);
      }

      // Apply field changes
      if (displayName != null) {
        updatedUser = updatedUser.copyWith(displayName: displayName);
      }
      if (targetStudyTime != null) {
        updatedUser = updatedUser.copyWith(targetStudyTime: targetStudyTime);
      }

      await _repository.updateUserProfile(updatedUser);
      // Invalidate dashboard stats ke refresh streak và study time
      _ref.invalidate(studyTimeStatsProvider);
      _ref.invalidate(targetStudyTimeProvider);
      state = state.copyWith(user: updatedUser);
      return true;
    } catch (e) {
      debugPrint('Failed to update profile: $e');
      state = state.copyWith(
        errorMessage: 'Cập nhật hồ sơ thất bại. Vui lòng thử lại.',
      );
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------
  Future<void> logout() async {
    try {
      await _repository.signOut();
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: 'Không thể đăng xuất. Vui lòng thử lại.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Reset Password
  // ---------------------------------------------------------------------------
  Future<bool> resetPassword(String email) async {
    try {
      await _repository.sendPasswordResetEmail(email);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(errorMessage: _mapFirebaseError(e.code));
      return false;
    } catch (e) {
      state =
          state.copyWith(errorMessage: 'Đã xảy ra lỗi. Vui lòng thử lại.');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Change Password
  // ---------------------------------------------------------------------------
  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    try {
      await _repository.changePassword(currentPassword, newPassword);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(errorMessage: _mapFirebaseError(e.code));
      return false;
    } catch (e) {
      state =
          state.copyWith(errorMessage: 'Đã xảy ra lỗi. Vui lòng thử lại.');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Utilities
  // ---------------------------------------------------------------------------
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Mật khẩu không chính xác.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
      case 'invalid-email':
        return 'Địa chỉ email không hợp lệ.';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa.';
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không chính xác.';
      default:
        return 'Đã xảy ra lỗi ($code). Vui lòng thử lại.';
    }
  }
}

// =============================================================================
// Providers
// =============================================================================
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository, ref);
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
});

