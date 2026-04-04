import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_academic_assistant/features/auth/models/user_model.dart';
import 'package:student_academic_assistant/features/auth/viewmodels/auth_viewmodel.dart';

/// Global provider that exposes the current authenticated user's profile.
/// Returns null when not authenticated.
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.user;
});