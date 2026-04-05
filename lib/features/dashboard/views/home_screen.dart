import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:student_academic_assistant/core/providers/theme_mode_provider.dart';
import 'package:student_academic_assistant/core/providers/user_provider.dart';
import 'package:student_academic_assistant/core/theme/app_theme.dart';
import 'package:student_academic_assistant/core/widgets/responsive_center.dart';
import 'package:student_academic_assistant/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:student_academic_assistant/features/dashboard/viewmodels/stats_viewmodel.dart';

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
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25), width: 1),
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
          _AppBarButton(
            icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            tooltip: isDark ? 'Chuyển giao diện sáng' : 'Chuyển giao diện tối',
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
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
          // (Removed debug Pomodoro quick-access button)
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

              // ── Today Stats (Streak + Task Completion) ──
              _TodayStatsCard(),

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
                  // Đã mở Flashcards, nên không hiển thị badge "Sắp ra mắt" toàn cục nữa.
                ],
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 14),

              _buildFeatureCard(
                context,
                icon: Icons.event_note_rounded,
                title: 'Nhắc lịch & Deadline',
                subtitle: 'Tạo task, đặt deadline, nhận nhắc đúng giờ',
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E88E5),
                    Color(0xFF42A5F5),
                  ],
                ),
                delay: 450,
                isAvailable: true,
                onTap: () => context.push('/tasks'),
              ),
              _buildFeatureCard(
                context,
                icon: Icons.quiz_rounded,
                title: 'Ôn tập & Flashcard',
                subtitle: 'Quiz thông minh, luyện tập hiệu quả',
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF3949AB),
                    Color(0xFF5C6BC0),
                  ],
                ),
                delay: 450,
                isAvailable: true,
                onTap: () => context.push('/study'),
              ),
              _buildFeatureCard(
                context,
                icon: Icons.calendar_month_rounded,
                title: 'Thời khóa biểu (OCR)',
                subtitle: 'Quét lịch học bằng camera nhanh chóng',
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00897B),
                    Color(0xFF4DB6AC),
                  ],
                ),
                delay: 530,
                isAvailable: true,
                onTap: () => context.push('/schedule'),
              ),
              _buildFeatureCard(
                context,
                icon: Icons.mic_rounded,
                title: 'Ghi chú giọng nói + AI',
                subtitle: 'Nói hoặc tải audio, AI tự tóm tắt theo gạch đầu dòng',
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF7B1FA2),
                    Color(0xFFAB47BC),
                  ],
                ),
                delay: 610,
                isAvailable: true,
                onTap: () => context.push('/notes-asr'),
              ),
              // Temporary explicit card to ensure tap/navigation works
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.20)
                            : const Color(0xFFE53935).withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.push('/pomodoro'),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE53935), Color(0xFFEF5350)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE53935).withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.timer_rounded, color: Colors.white, size: 24),
                        ),
                        title: const Text('Pomodoro Timer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text('Tập trung sâu & Deep Work Mode', style: TextStyle(fontSize: 12.5, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55))),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935).withValues(alpha: isDark ? 0.20 : 0.10),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFE53935), size: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _buildFeatureCard(
                context,
                icon: Icons.bar_chart_rounded,
                title: 'Thống kê & Báo cáo',
                subtitle: 'Biểu đồ tiến độ học tập theo thời gian',
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFF57C00),
                    Color(0xFFFFB74D),
                  ],
                ),
                delay: 770,
                isAvailable: true,
                onTap: () => context.push('/statistics'),
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
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
                color: Colors.white.withValues(alpha: 0.03),
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
                color: Colors.white.withValues(alpha: 0.02),
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
                        color: Colors.white.withValues(alpha: 0.18),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35), width: 2),
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
                            color: Colors.white.withValues(alpha: 0.75),
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
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25), width: 1),
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
                color: Colors.white.withValues(alpha: 0.15),
              ),
              const SizedBox(height: 14),
              Text(
                user?.email ?? '',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '"Hãy bắt đầu 1 ngày học tập thật hiệu quả nào!"',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.80),
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

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required int delay,
    bool isAvailable = false,
    VoidCallback? onTap,
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
                  ? Colors.black.withValues(alpha: 0.20)
                  : baseColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isAvailable ? onTap : null,
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
                      color: baseColor.withValues(alpha: 0.35),
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
                        .withValues(alpha: 0.55),
                  ),
                ),
              ),
              trailing: isAvailable
                  ? Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: baseColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_forward_ios_rounded,
                          color: baseColor, size: 14),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: baseColor.withValues(alpha: isDark ? 0.20 : 0.10),
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

/// Widget hiển thị Streak + Phút học hôm nay + Tasks trong 1 hàng
class _TodayStatsCard extends ConsumerWidget {
  const _TodayStatsCard();

  // Mục tiêu học tập mỗi ngày (phút)
  static const int _dailyStudyGoal = 240; // 4 giờ

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studyTimeStats = ref.watch(studyTimeStatsProvider);
    final quizStats = ref.watch(quizStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return studyTimeStats.when(
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (studyStats) {
        return quizStats.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (quizData) {
            final colorScheme = Theme.of(context).colorScheme;
            final theme = Theme.of(context);

            // Lấy phút học hôm nay (thứ hôm nay)
            final todayIndex = DateTime.now().weekday - 1;
            final todayMinutes = studyStats.dailyMinutes[todayIndex];
            
            // Điều kiện màu sắc
            final isStreakActive = todayMinutes >= 30; // Hôm nay đã đủ 30 phút
            final isStudyGoalMet = todayMinutes >= _dailyStudyGoal; // Đạt mục tiêu hôm nay

            // Màu text cho dark mode
            final textColor = isDark ? Colors.white : colorScheme.onSurface;
            final labelColor = isDark 
                ? Colors.white.withValues(alpha: 0.7)
                : colorScheme.outline;

            return Row(
              children: [
                // Streak Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isStreakActive
                          ? Colors.red.withValues(alpha: isDark ? 0.25 : 0.12)
                          : colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isStreakActive
                            ? Colors.red.withValues(alpha: 0.4)
                            : colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Streak',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: labelColor,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.local_fire_department_rounded,
                              color: isStreakActive ? Colors.red : colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${studyStats.streak}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isStreakActive ? Colors.red : colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'ngày',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: labelColor,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Study Minutes Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isStudyGoalMet
                          ? Colors.green.withValues(alpha: isDark ? 0.25 : 0.12)
                          : colorScheme.tertiary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isStudyGoalMet
                            ? Colors.green.withValues(alpha: 0.4)
                            : colorScheme.tertiary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hôm nay',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: labelColor,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              color: isStudyGoalMet ? Colors.green : colorScheme.tertiary,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$todayMinutes',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isStudyGoalMet ? Colors.green : colorScheme.tertiary,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'phút',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: labelColor,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Task Completion Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.secondary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tasks',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: labelColor,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: colorScheme.secondary,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${quizData.taskCompletionPercentage.toStringAsFixed(0)}%',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
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
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.20), width: 1),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

