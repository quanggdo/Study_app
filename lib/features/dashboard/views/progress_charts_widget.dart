import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodels/stats_viewmodel.dart';
import '../models/dashboard_stats_model.dart';

/// Widget hiển thị biểu đồ thống kê tiến độ học tập theo MVVM pattern
class ProgressChartsWidget extends ConsumerWidget {
  const ProgressChartsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardStats = ref.watch(dashboardStatsProvider);

    return dashboardStats.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Không thể tải dữ liệu thống kê'),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      data: (stats) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card 1: Thống kê thời gian học
              _StudyTimeStatCard(
                studyStats: stats.studyTimeStats,
              ),
              const SizedBox(height: 16),
              // Card 2: Thống kê điểm số và hoàn thành tasks
              _QuizStatCard(
                quizStats: stats.quizStats,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Card hiển thị thống kê thời gian học
class _StudyTimeStatCard extends StatelessWidget {
  final StudyTimeStats studyStats;

  const _StudyTimeStatCard({required this.studyStats});

  static const List<String> _dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Kiểm tra xem có dữ liệu không
    final hasData = studyStats.dailyMinutes.any((m) => m > 0);

    if (!hasData) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thống kê thời gian học',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.trending_up_outlined,
                      size: 48,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Chưa có dữ liệu',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bắt đầu một phiên Pomodoro để thu thập dữ liệu',
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final maxMinutes = studyStats.dailyMinutes.reduce((a, b) => a > b ? a : b);
    final chartMaxY = (maxMinutes * 1.2).ceilToDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với tiêu đề và streak
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thống kê thời gian học',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Phút/tuần',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                // Chip hiển thị streak
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${studyStats.streak} ngày',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Biểu đồ cột
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: chartMaxY,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => colorScheme.surface,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toInt()} phút',
                          TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: theme.textTheme.labelSmall,
                            textAlign: TextAlign.right,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < _dayLabels.length) {
                            return Text(
                              _dayLabels[index],
                              style: theme.textTheme.labelSmall,
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                      left: BorderSide(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: chartMaxY / 4,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: colorScheme.outline.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  barGroups: List.generate(
                    studyStats.dailyMinutes.length,
                    (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: studyStats.dailyMinutes[index].toDouble(),
                            color: colorScheme.primary,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                            width: 20,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tóm tắt dữ liệu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  bool isNarrow = constraints.maxWidth < 280;
                  return isNarrow
                      ? Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'Tổng tuần',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: colorScheme.outline,
                                      ),
                                    ),
                                    Text(
                                      '${studyStats.totalMinutes}',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Divider(
                              color: colorScheme.outline.withOpacity(0.3),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'Trung bình/ngày',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: colorScheme.outline,
                                      ),
                                    ),
                                    Text(
                                      (studyStats.totalMinutes / 7).toStringAsFixed(0),
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Tổng tuần',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.outline,
                                  ),
                                ),
                                Text(
                                  '${studyStats.totalMinutes}',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            VerticalDivider(
                              color: colorScheme.outline.withOpacity(0.3),
                            ),
                            Column(
                              children: [
                                Text(
                                  'Trung bình/ngày',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.outline,
                                  ),
                                ),
                                Text(
                                  (studyStats.totalMinutes / 7).toStringAsFixed(0),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card hiển thị thống kê điểm số và hoàn thành tasks
class _QuizStatCard extends StatelessWidget {
  final QuizStatsData quizStats;

  const _QuizStatCard({required this.quizStats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Thống kê điểm số Trắc nghiệm',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            // Kiểm tra xem có quiz nào không
            if (quizStats.quizScores.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        size: 48,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Chưa có kết quả quiz',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Biểu đồ cột so sánh điểm cao nhất và trung bình
              _QuizScoresChart(quizScores: quizStats.quizScores),
              const SizedBox(height: 24),
            ],
            // Tỷ lệ hoàn thành Tasks
            _TaskCompletionSection(
              completionPercentage: quizStats.taskCompletionPercentage,
            ),
          ],
        ),
      ),
    );
  }
}

/// Biểu đồ cột so sánh điểm cao nhất và trung bình cho mỗi quiz
class _QuizScoresChart extends StatelessWidget {
  final List<QuizScoreData> quizScores;

  const _QuizScoresChart({required this.quizScores});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Giới hạn số lượng quiz hiển thị để không quá nhiều
    final displayedQuizzes = quizScores.take(5).toList();
    const maxScore = 10.0; // Thang điểm 10

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Wrap(
            spacing: 32,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Điểm cao nhất',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Điểm trung bình',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
        // Biểu đồ
        SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxScore,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => colorScheme.surface,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final score = rod.toY;
                    final label = rodIndex == 0 ? 'Cao nhất' : 'Trung bình';
                    return BarTooltipItem(
                      '$label: ${score.toStringAsFixed(1)}/10',
                      TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: theme.textTheme.labelSmall,
                        textAlign: TextAlign.right,
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < displayedQuizzes.length) {
                        final title = displayedQuizzes[index].quizTitle;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SizedBox(
                            width: 60,
                            child: Text(
                              title,
                              style: theme.textTheme.labelSmall,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                  left: BorderSide(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: colorScheme.outline.withOpacity(0.1),
                    strokeWidth: 1,
                  );
                },
              ),
              barGroups: List.generate(
                displayedQuizzes.length,
                (index) {
                  final quiz = displayedQuizzes[index];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      // Điểm cao nhất - màu cam, chia cho 10
                      BarChartRodData(
                        toY: quiz.highestScore / 10,
                        color: Colors.orange,
                        width: 12,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                      // Điểm trung bình - màu xanh, chia cho 10
                      BarChartRodData(
                        toY: quiz.averageScore / 10,
                        color: Colors.green,
                        width: 12,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Section hiển thị vòng tròn và tỉ lệ hoàn thành Tasks
class _TaskCompletionSection extends StatelessWidget {
  final double completionPercentage;

  const _TaskCompletionSection({required this.completionPercentage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tỉ lệ hoàn thành Tasks',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Biểu đồ tròn tiến trình
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: completionPercentage / 100,
                    strokeWidth: 8,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                ),
                // Text ở giữa
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${completionPercentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hoàn thành',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.outline,
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
  }
}