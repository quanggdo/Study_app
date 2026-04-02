import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/responsive_center.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'widgets/auth_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final String? email;

  const ForgotPasswordScreen({super.key, this.email});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref
          .read(authNotifierProvider.notifier)
          .resetPassword(_emailController.text);
      if (success && mounted) {
        setState(() => _emailSent = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authNotifierProvider);

    // Show error snackbar
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.arrow_back_rounded,
                color: colorScheme.primary, size: 20),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Quên mật khẩu',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ResponsiveCenter(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _emailSent
              ? _buildSuccessState(context, colorScheme, isDark)
              : _buildForm(context, colorScheme, isDark, authState),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, ColorScheme colorScheme, bool isDark,
      AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),

        // Hero icon
        Center(
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3949AB).withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              size: 44,
              color: Colors.white,
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(
              begin: const Offset(0.7, 0.7),
              curve: Curves.easeOutBack,
            ),

        const SizedBox(height: 32),

        Text(
          'Đặt lại mật khẩu',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 10),

        Text(
          'Nhập địa chỉ email đã đăng ký. Chúng tôi sẽ gửi link đặt lại mật khẩu tới email của bạn.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),

        const SizedBox(height: 36),

        // Card form
        Container(
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
                AuthTextField(
                  controller: _emailController,
                  label: 'Email đã đăng ký',
                  hint: 'example@email.com',
                  prefixIcon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleResetPassword(),
                  validator: Validators.validateEmail,
                  readOnly: true,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.08),

                const SizedBox(height: 24),

                // Submit button
                _buildSubmitButton(authState),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.06),
      ],
    );
  }

  Widget _buildSubmitButton(AuthState authState) {
    final isLoading = authState.status == AuthStatus.loading;
    return SizedBox(
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isLoading
              ? LinearGradient(colors: [
                  Colors.grey.withOpacity(0.5),
                  Colors.grey.withOpacity(0.4),
                ])
              : AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: !isLoading
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
          onPressed: isLoading ? null : _handleResetPassword,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Gửi link đặt lại',
                      style: TextStyle(
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

  Widget _buildSuccessState(
      BuildContext context, ColorScheme colorScheme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),

        // Success icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.shade400,
                Colors.green.shade600,
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            size: 50,
            color: Colors.white,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(
              begin: const Offset(0.5, 0.5),
              curve: Curves.easeOutBack,
            ),

        const SizedBox(height: 32),

        Text(
          'Email đã được gửi!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.green.withOpacity(0.10)
                : Colors.green.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.green.withOpacity(0.25),
            ),
          ),
          child: Text(
            'Vui lòng kiểm tra hộp thư email\n${_emailController.text}\nđể đặt lại mật khẩu.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
        ).animate().fadeIn(delay: 400.ms),

        const SizedBox(height: 40),

        SizedBox(
          height: 54,
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3949AB).withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: MaterialButton(
              onPressed: () => context.go('/login'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              splashColor: Colors.white.withOpacity(0.2),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Quay lại đăng nhập',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.08),

        const SizedBox(height: 16),

        TextButton.icon(
          onPressed: () => setState(() => _emailSent = false),
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Gửi lại email'),
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.primary,
          ),
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }
}
