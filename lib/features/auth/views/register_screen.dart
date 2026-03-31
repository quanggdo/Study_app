import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/validators.dart';
import '../viewmodels/auth_viewmodel.dart';
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
    final isLoading = authState.status == AuthStatus.loading;

    // Show error snackbar
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Gradient Header ──
            const AuthHeader(
              title: 'Tạo tài khoản',
              subtitle: 'Bắt đầu hành trình học tập của bạn',
              icon: Icons.person_add_rounded,
            ),

            // ── Form ──
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    // Display Name
                    AuthTextField(
                      controller: _nameController,
                      label: 'Họ và tên',
                      hint: 'Nguyễn Văn A',
                      prefixIcon: Icons.person_rounded,
                      textInputAction: TextInputAction.next,
                      validator: Validators.validateDisplayName,
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

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
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

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
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),

                    const SizedBox(height: 16),

                    // Confirm Password
                    AuthTextField(
                      controller: _confirmPasswordController,
                      label: 'Xác nhận mật khẩu',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleRegister(),
                      validator: (value) => Validators.validateConfirmPassword(
                        value,
                        _passwordController.text,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),

                    const SizedBox(height: 24),

                    // Register button
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: isLoading ? null : _handleRegister,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Đăng ký',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),



                    const SizedBox(height: 32),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Đã có tài khoản? ',
                          style:
                              TextStyle(color: colorScheme.onSurfaceVariant),
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
                    ).animate().fadeIn(delay: 1100.ms),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
