import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/viewmodels/auth_viewmodel.dart';
import '../../features/auth/views/change_password_screen.dart';
import '../../features/auth/views/forgot_password_screen.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/profile_screen.dart';
import '../../features/auth/views/register_screen.dart';
import '../../features/dashboard/views/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // ValueNotifier to trigger GoRouter refresh on auth state change
  final refreshNotifier = ValueNotifier<int>(0);

  ref.listen<AuthState>(authNotifierProvider, (_, __) {
    refreshNotifier.value++;
  });

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);

      // Don't redirect while auth state is still initializing
      if (authState.status == AuthStatus.initial) return null;

      final isAuthenticated = authState.status == AuthStatus.authenticated;

      final publicRoutes = ['/login', '/register', '/forgot-password'];
      final isOnPublicRoute = publicRoutes.contains(state.matchedLocation);

      // Not authenticated & trying to access protected route → login
      if (!isAuthenticated && !isOnPublicRoute) return '/login';

      // Authenticated & on public route → home
      if (isAuthenticated && isOnPublicRoute) return '/home';

      return null; // No redirect
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
