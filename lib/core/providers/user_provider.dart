import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/models/user_model.dart';
import '../../features/auth/viewmodels/auth_viewmodel.dart';

/// Global provider that exposes the current authenticated user's profile.
/// Returns null when not authenticated.
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.user;
});