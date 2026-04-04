import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:student_academic_assistant/core/theme/app_theme.dart';
import 'package:student_academic_assistant/core/utils/validators.dart';
import 'package:student_academic_assistant/core/widgets/responsive_center.dart';
import 'package:student_academic_assistant/features/auth/viewmodels/auth_viewmodel.dart';

import 'widgets/auth_header.dart';
import 'widgets/auth_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authNotifierProvider.notifier).login(
            _emailController.text,
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = authState.status == AuthStatus.loading;

    // Show error snackbar
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(next.errorMessage!)),
              ],
            ),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1117)
          : const Color(0xFFF5F6FA),
      body: ResponsiveCenter(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Gradient Header ──
              const AuthHeader(
                title: 'Chào mừng\ntrở lại!',
                subtitle: 'Đăng nhập để tiếp tục hành trình học tập',
                icon: Icons.school_rounded,
              ),

              // ── Form Card ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1C1F2E)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.35)
                            : const Color(0xFF3949AB).withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Section label
                        Text(
                          'Thông tin đăng nhập',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                        ).animate().fadeIn(delay: 300.ms),

                        const SizedBox(height: 20),

                        // Email
                        AuthTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'example@email.com',
                          prefixIcon: Icons.email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: Validators.validateEmail,
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.08),

                        const SizedBox(height: 16),

                        // Password
                        AuthTextField(
                          controller: _passwordController,
                          label: 'Mật khẩu',
                          prefixIcon: Icons.lock_rounded,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleLogin(),
                          validator: Validators.validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.08),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              final email = _emailController.text.trim();
                              if (email.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                                        SizedBox(width: 10),
                                        Expanded(child: Text('Vui lòng nhập email trước khi lấy lại mật khẩu')),
                                      ],
                                    ),
                                    backgroundColor: colorScheme.error,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    margin: const EdgeInsets.all(16),
                                  ),
                                );
                                return;
                              }
                              context.push('/forgot-password?email=$email');
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 8),
                            ),
                            child: const Text(
                              'Quên mật khẩu?',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ).animate().fadeIn(delay: 600.ms),

                        const SizedBox(height: 4),

                        // Login button
                        _GradientButton(
                          onPressed: isLoading ? null : _handleLogin,
                          isLoading: isLoading,
                          label: 'Đăng nhập',
                          icon: Icons.login_rounded,
                        ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.08),

                        const SizedBox(height: 32),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: colorScheme.outline
                                        .withOpacity(0.25))),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'HOẶC',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color:
                                          colorScheme.onSurface.withOpacity(0.4),
                                      letterSpacing: 1.5,
                                    ),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                    color: colorScheme.outline
                                        .withOpacity(0.25))),
                          ],
                        ).animate().fadeIn(delay: 800.ms),

                        const SizedBox(height: 24),

                        // Register link
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            Text(
                              'Chưa có tài khoản?',
                              style: TextStyle(
                                  color: colorScheme.onSurfaceVariant),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/register'),
                              child: Text(
                                'Đăng ký ngay',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 900.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Gradient Button
// =============================================================================

class _GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;
  final IconData icon;

  const _GradientButton({
    required this.onPressed,
    required this.isLoading,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed == null
              ? LinearGradient(
                  colors: [
                    Colors.grey.withOpacity(0.5),
                    Colors.grey.withOpacity(0.4),
                  ],
                )
              : AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: onPressed != null
              ? [
                  BoxShadow(
                    color: const Color(0xFF3949AB).withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: MaterialButton(
          onPressed: onPressed,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          splashColor: Colors.white.withOpacity(0.2),
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}