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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authNotifierProvider.notifier).register(
            _emailController.text,
            _passwordController.text,
            _nameController.text.trim(),
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
                title: 'Tạo tài khoản\nmới',
                subtitle: 'Bắt đầu hành trình học tập thông minh',
                icon: Icons.person_add_rounded,
              ),

              // ── Form Card ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
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
                          'Thông tin cá nhân',
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

                        // Display Name
                        AuthTextField(
                          controller: _nameController,
                          label: 'Họ và tên',
                          hint: 'Nguyễn Văn A',
                          prefixIcon: Icons.person_rounded,
                          textInputAction: TextInputAction.next,
                          validator: Validators.validateDisplayName,
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.08),

                        const SizedBox(height: 16),

                        // Email
                        AuthTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'example@email.com',
                          prefixIcon: Icons.email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: Validators.validateEmail,
                        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.08),

                        const SizedBox(height: 20),

                        // Divider with label
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color:
                                        colorScheme.outline.withOpacity(0.2))),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'Mật khẩu',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                    color:
                                        colorScheme.outline.withOpacity(0.2))),
                          ],
                        ).animate().fadeIn(delay: 550.ms),

                        const SizedBox(height: 16),

                        // Password
                        AuthTextField(
                          controller: _passwordController,
                          label: 'Mật khẩu',
                          prefixIcon: Icons.lock_rounded,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
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
                        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.08),

                        const SizedBox(height: 16),

                        // Confirm Password
                        AuthTextField(
                          controller: _confirmPasswordController,
                          label: 'Xác nhận mật khẩu',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscureConfirm,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleRegister(),
                          validator: (value) =>
                              Validators.validateConfirmPassword(
                            value,
                            _passwordController.text,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                          ),
                        ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.08),

                        const SizedBox(height: 28),

                        // Register button
                        _GradientButton(
                          onPressed: isLoading ? null : _handleRegister,
                          isLoading: isLoading,
                          label: 'Tạo tài khoản',
                          icon: Icons.person_add_rounded,
                        ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.08),

                        const SizedBox(height: 28),

                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Đã có tài khoản? ',
                              style: TextStyle(
                                  color: colorScheme.onSurfaceVariant),
                            ),
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: Text(
                                'Đăng nhập',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 900.ms),

                        const SizedBox(height: 8),
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
              ? LinearGradient(colors: [
                  Colors.grey.withOpacity(0.5),
                  Colors.grey.withOpacity(0.4),
                ])
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
