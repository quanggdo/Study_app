import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_center.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.heroGradient,
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.white.withOpacity(0.25), width: 1),
              ),
              child: const Icon(Icons.school_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'SAA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          // Profile
          _AppBarButton(
            icon: Icons.person_rounded,
            tooltip: 'Hồ sơ cá nhân',
            onPressed: () => context.push('/profile'),
          ),
          // Change password
          _AppBarButton(
            icon: Icons.lock_outline_rounded,
            tooltip: 'Đổi mật khẩu',
            onPressed: () => context.push('/change-password'),
          ),
          // Logout
          _AppBarButton(
            icon: Icons.logout_rounded,
            tooltip: 'Đăng xuất',
            onPressed: () => _showLogoutDialog(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ResponsiveCenter(
        maxWidth: 600,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Welcome Card ──
              _buildWelcomeCard(context, user, colorScheme, isDark),

              const SizedBox(height: 28),

              // ── Quick Stats ──
              Text(
                'Tổng quan hôm nay',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 14),

              _buildQuickStats(context, colorScheme, isDark),

              const SizedBox(height: 28),

              // ── Features ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tính năng',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Sắp ra mắt',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 14),

              _buildFeatureCard(
                context,
                icon: Icons.quiz_rounded,
                title: 'Ôn tập & Flashcard',
                subtitle: 'Quiz thông minh, luyện tập hiệu quả',
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3949AB),
                    const Color(0xFF5C6BC0),
                  ],
                ),
                delay: 450,
              ),
              _buildFeatureCard(
                context,
                icon: Icons.calendar_month_rounded,
                title: 'Thời khóa biểu (OCR)',
                subtitle: 'Quét lịch học bằng camera nhanh chóng',
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00897B),
                    const Color(0xFF4DB6AC),
                  ],
                ),
                delay: 530,
              ),
              _buildFeatureCard(
                context,
                icon: Icons.mic_rounded,
                title: 'Ghi chú thông minh',
                subtitle: 'Ghi chú bằng giọng nói (ASR)',
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF7B1FA2),
                    const Color(0xFFAB47BC),
                  ],
                ),
                delay: 610,
              ),
              _buildFeatureCard(
                context,
                icon: Icons.timer_rounded,
                title: 'Pomodoro Timer',
                subtitle: 'Tập trung sâu & Deep Work Mode',
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE53935),
                    const Color(0xFFEF5350),
                  ],
                ),
                delay: 690,
              ),
              _buildFeatureCard(
                context,
                icon: Icons.bar_chart_rounded,
                title: 'Thống kê & Báo cáo',
                subtitle: 'Biểu đồ tiến độ học tập theo thời gian',
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF57C00),
                    const Color(0xFFFFB74D),
                  ],
                ),
                delay: 770,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, dynamic user,
      ColorScheme colorScheme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3949AB).withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // decorative element
          Positioned(
            right: -10,
            top: -10,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.18),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.35), width: 2),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: user?.photoUrl != null &&
                              user!.photoUrl!.isNotEmpty
                          ? Image.network(
                              user.photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            )
                          : const Icon(Icons.person_rounded,
                              color: Colors.white, size: 28),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xin chào,',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          user?.displayName ?? 'Sinh viên',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.25), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded,
                            color: Colors.yellow.shade300, size: 14),
                        const SizedBox(width: 3),
                        const Text(
                          'Active',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: Colors.white.withOpacity(0.15),
              ),
              const SizedBox(height: 14),
              Text(
                user?.email ?? '',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '"Học không bao giờ là muộn — mỗi ngày là một cơ hội mới."',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.80),
                  fontSize: 12.5,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05);
  }

  Widget _buildQuickStats(
      BuildContext context, ColorScheme colorScheme, bool isDark) {
    final stats = [
      _StatItem(
          icon: Icons.local_fire_department_rounded,
          label: 'Streak',
          value: '0 ngày',
          color: Colors.orange),
      _StatItem(
          icon: Icons.timer_rounded,
          label: 'Đã học',
          value: '0 phút',
          color: const Color(0xFF3949AB)),
      _StatItem(
          icon: Icons.task_alt_rounded,
          label: 'Task',
          value: '0/0',
          color: Colors.green),
    ];

    return Row(
      children: stats.asMap().entries.map((entry) {
        final stat = entry.value;
        final delay = 350 + entry.key * 80;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: entry.key < stats.length - 1 ? 10 : 0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.25)
                        : const Color(0xFF3949AB).withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: stat.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(stat.icon, color: stat.color, size: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    stat.value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stat.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.06),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required int delay,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = gradient.colors.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.20)
                  : baseColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: baseColor.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.5,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.55),
              ),
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: baseColor.withOpacity(isDark ? 0.20 : 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Sắp có',
              style: TextStyle(
                color: baseColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.04);
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.logout_rounded, size: 40),
        title: const Text('Đăng xuất',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất không?',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Hủy'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authNotifierProvider.notifier).logout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Helper classes
// =============================================================================

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _AppBarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _AppBarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: Colors.white.withOpacity(0.20), width: 1),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
