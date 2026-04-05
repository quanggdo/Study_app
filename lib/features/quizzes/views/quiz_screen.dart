import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/quiz_viewmodel.dart';
import 'widgets/quiz_loading_shimmer.dart';
import 'quiz_history_screen.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key, required this.quizId});

  final String quizId;

  String _formatRemaining(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  int _remainingFromEnd(DateTime? endAt) {
    if (endAt == null) return 0;
    final diff = endAt.difference(DateTime.now()).inSeconds;
    return diff < 0 ? 0 : diff;
  }

  Future<bool> _confirmExitQuiz(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Thoát bài làm?'),
            content: const Text('Bạn có chắc muốn thoát không? Tiến trình làm bài hiện tại sẽ bị hủy.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Không'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Có'),
              ),
            ],
          ),
        ) ??
        false;

      if (!context.mounted) return false;

    if (!shouldExit) return false;

    context.go('/home');
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizSessionProvider(quizId));
    final vm = ref.read(quizSessionProvider(quizId).notifier);

    final quiz = state.quiz;

    if (state.loading) {
      return const Scaffold(
        body: SafeArea(child: QuizLoadingShimmer()),
      );
    }

    if (state.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: Center(child: Text('Lỗi: ${state.error}')),
      );
    }

    if (quiz == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('Không tìm thấy quiz.')),
      );
    }

    if (state.result != null) {
      return _QuizResultView(
        title: quiz.title,
        quiz: quiz,
        result: state.result!,
        onBack: () => Navigator.of(context).pop(),
        onViewHistory: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => QuizHistoryScreen(quizId: quiz.id),
            ),
          );
        },
        onViewLastAttempt: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => QuizLastAttemptScreen(quizId: quiz.id),
            ),
          );
        },
      );
    }

    final q = vm.currentQuestion;
    if (q == null) {
      return Scaffold(
        appBar: AppBar(title: Text(quiz.title)),
        body: const Center(child: Text('Quiz trống.')),
      );
    }

    final selected = state.answersByQId[q.qId];

    final total = quiz.questions.length;
    final answeredCount = state.answersByQId.length;

    final remaining = state.remainingSeconds ?? _remainingFromEnd(state.endAt);
    final isTimeLimited = quiz.timeLimit != null && quiz.timeLimit! > 0;

    final danger = isTimeLimited && remaining <= 30;

    return _QuizScreenLifecycle(
      onResume: vm.refreshRemaining,
      child: WillPopScope(
        onWillPop: () => _confirmExitQuiz(context),
        child: Scaffold(
          appBar: AppBar(
            title: Text(quiz.title),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () async {
                await _confirmExitQuiz(context);
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              if (state.timeUp)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .errorContainer
                        .withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_rounded,
                          color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text('Đã hết giờ. Bài sẽ được nộp tự động.'),
                      ),
                    ],
                  ),
                ),

              Row(
                children: [
                  Text('Câu ${state.index + 1}/$total'),
                  const Spacer(),
                  Text('$answeredCount/$total đã trả lời'),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Tổng quan câu hỏi',
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        showDragHandle: true,
                        isScrollControlled: true,
                        builder: (ctx) {
                          return _QuestionOverviewSheet(
                            title: quiz.title,
                            total: total,
                            currentIndex: state.index,
                            qIds: quiz.questions.map((e) => e.qId).toList(),
                            answeredQIds: state.answersByQId.keys.toSet(),
                            onJump: (i) {
                              Navigator.pop(ctx);
                              vm.jumpTo(i);
                            },
                            onJumpFirstUnanswered: () {
                              final qIds = quiz.questions.map((e) => e.qId).toList();
                              final answered = state.answersByQId.keys.toSet();
                              final first = qIds.indexWhere((id) => !answered.contains(id));
                              if (first >= 0) {
                                Navigator.pop(ctx);
                                vm.jumpTo(first);
                              }
                            },
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.grid_view_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Quick question grid
              _QuestionGrid(
                total: total,
                currentIndex: state.index,
                answeredQIds: state.answersByQId.keys.toSet(),
                qIds: quiz.questions.map((e) => e.qId).toList(),
                onJump: vm.jumpTo,
              ),

              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    q.question.trim().isNotEmpty
                        ? q.question
                        : 'Câu hỏi ${state.index + 1}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 220.ms)
                  .slideY(begin: 0.06, end: 0, duration: 220.ms),

              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: q.choices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final c = q.choices[i];
                    final isSelected = selected == c.id;
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: state.submitting || state.timeUp
                          ? null
                          : () => vm.selectChoice(qId: q.qId, choiceId: c.id),
                      child: Ink(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).dividerColor,
                          ),
                          color: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                              ),
                              child: Text(
                                c.id,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                c.text,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 200.ms, delay: (40 * i).ms)
                        .slideX(begin: 0.02, end: 0, duration: 200.ms);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: state.index == 0 || state.submitting || state.timeUp
                          ? null
                          : vm.back,
                      child: const Text('Trước'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: state.submitting || state.timeUp
                          ? null
                          : (state.index == total - 1 ? vm.submit : vm.next),
                      child: state.submitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(state.index == total - 1 ? 'Nộp bài' : 'Tiếp'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: state.submitting || state.timeUp
                          ? null
                          : () async {
                              final unanswered = total - answeredCount;
                              final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      title: const Text('Nộp bài?'),
                                      content: Text(
                                        unanswered > 0
                                            ? 'Bạn còn $unanswered câu chưa trả lời. Vẫn nộp bài chứ?'
                                            : 'Bạn đã trả lời hết. Nộp bài chứ?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: const Text('Hủy'),
                                        ),
                                        FilledButton(
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text('Nộp'),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;

                              if (!ok) return;
                              await vm.submit();
                            },
                      child: Text(
                          'Nộp bài ngay (${total - answeredCount} chưa trả lời)'),
                    ),
                  ),
                  if (isTimeLimited) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: danger
                            ? Theme.of(context)
                                .colorScheme
                                .error
                                .withValues(alpha: 0.12)
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: danger
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_rounded,
                            size: 16,
                            color: danger
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatRemaining(remaining),
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: danger
                                      ? Theme.of(context).colorScheme.error
                                      : Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionGrid extends StatelessWidget {
  const _QuestionGrid({
    required this.total,
    required this.currentIndex,
    required this.answeredQIds,
    required this.qIds,
    required this.onJump,
  });

  final int total;
  final int currentIndex;
  final Set<String> answeredQIds;
  final List<String> qIds;
  final ValueChanged<int> onJump;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: total,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final qId = qIds[i];
          final isCurrent = i == currentIndex;
          final isAnswered = answeredQIds.contains(qId);

          Color bg;
          Color fg;
          Color border;

          if (isCurrent) {
            bg = Theme.of(context).colorScheme.primary;
            fg = Theme.of(context).colorScheme.onPrimary;
            border = Theme.of(context).colorScheme.primary;
          } else if (isAnswered) {
            bg = Theme.of(context)
                .colorScheme
                .secondaryContainer
                .withValues(alpha: 0.8);
            fg = Theme.of(context).colorScheme.onSecondaryContainer;
            border = Theme.of(context).colorScheme.secondary;
          } else {
            bg = Theme.of(context).colorScheme.surfaceContainerHighest;
            fg = Theme.of(context).colorScheme.onSurface;
            border = Theme.of(context).dividerColor;
          }

          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => onJump(i),
            child: Container(
              width: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: border),
              ),
              child: Text(
                '${i + 1}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: fg,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuizResultView extends StatelessWidget {
  const _QuizResultView({
    required this.title,
    required this.quiz,
    required this.result,
    required this.onBack,
    required this.onViewHistory,
    required this.onViewLastAttempt,
  });

  final String title;
  final dynamic result;
  final dynamic quiz;
  final VoidCallback onBack;
  final VoidCallback onViewHistory;
  final VoidCallback onViewLastAttempt;

  Color _choiceColor({
    required BuildContext context,
    required bool isUserChoice,
    required bool isCorrectChoice,
  }) {
    if (isUserChoice && isCorrectChoice) {
      return Theme.of(context).colorScheme.tertiaryContainer;
    }
    if (isUserChoice && !isCorrectChoice) {
      return Theme.of(context).colorScheme.errorContainer;
    }
    if (!isUserChoice && isCorrectChoice) {
      return Theme.of(context).colorScheme.secondaryContainer;
    }
    return Theme.of(context).colorScheme.surfaceContainerHighest;
  }

  Color _choiceBorder({
    required BuildContext context,
    required bool isUserChoice,
    required bool isCorrectChoice,
  }) {
    if (isUserChoice && isCorrectChoice) {
      return Theme.of(context).colorScheme.tertiary;
    }
    if (isUserChoice && !isCorrectChoice) {
      return Theme.of(context).colorScheme.error;
    }
    if (!isUserChoice && isCorrectChoice) {
      return Theme.of(context).colorScheme.secondary;
    }
    return Theme.of(context).dividerColor;
  }

  @override
  Widget build(BuildContext context) {
    // result là QuizGradingResult, nhưng để tránh import vòng trong placeholder, dùng dynamic.
    final score = (result.score as int);
    final total = (result.total as int);
    final review = (result.review as List);
    final questions = (quiz.questions as List);

    final score10 = total == 0 ? 0.0 : (score * 10 / total).clamp(0, 10);

    final reviewByQId = {
      for (final item in review)
        (item.qId as String): item,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Kết quả • $title'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      '$score/$total',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Điểm: ${score10.toStringAsFixed(1)}/10',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewHistory,
                    icon: const Icon(Icons.history_rounded),
                    label: const Text('Xem lịch sử'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onViewLastAttempt,
                    icon: const Icon(Icons.playlist_add_check_rounded),
                    label: const Text('Review vừa làm'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: questions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final q = questions[i] as dynamic;
                  final qId = q.qId as String;
                  final qTextRaw = (q.question ?? '').toString().trim();
                  final qText = qTextRaw.isNotEmpty ? qTextRaw : 'Câu hỏi ${i + 1}';
                  final choices = q.choices as List;

                  final item = reviewByQId[qId] as dynamic;
                  final user = (item?.userChoice ?? '').toString();
                  final correct = (item?.correctChoice ?? '').toString();
                  final ok = (item?.isCorrect ?? false) as bool;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                ok ? Icons.check_circle : Icons.cancel,
                                color: ok
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Câu ${i + 1}: $qText',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...choices.map((c) {
                            final choice = c as dynamic;
                            final choiceId = (choice.id ?? '').toString();
                            final choiceText = (choice.text ?? '').toString();

                            final isUserChoice = user == choiceId && user.isNotEmpty;
                            final isCorrectChoice =
                                correct == choiceId && correct.isNotEmpty;

                            final bg = _choiceColor(
                              context: context,
                              isUserChoice: isUserChoice,
                              isCorrectChoice: isCorrectChoice,
                            );
                            final border = _choiceBorder(
                              context: context,
                              isUserChoice: isUserChoice,
                              isCorrectChoice: isCorrectChoice,
                            );

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: border),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 26,
                                    height: 26,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: border,
                                    ),
                                    child: Text(
                                      choiceId,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(choiceText)),
                                  if (isCorrectChoice)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                      ),
                                    ),
                                  if (isUserChoice && !isCorrectChoice)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Icon(
                                        Icons.close_rounded,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                          if (user.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Bạn chưa trả lời câu này.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onBack,
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionOverviewSheet extends StatelessWidget {
  const _QuestionOverviewSheet({
    required this.title,
    required this.total,
    required this.currentIndex,
    required this.qIds,
    required this.answeredQIds,
    required this.onJump,
    required this.onJumpFirstUnanswered,
  });

  final String title;
  final int total;
  final int currentIndex;
  final List<String> qIds;
  final Set<String> answeredQIds;
  final ValueChanged<int> onJump;
  final VoidCallback onJumpFirstUnanswered;

  @override
  Widget build(BuildContext context) {
    final unanswered = total - answeredQIds.length;

    Widget legendDot(Color color) => Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        );

    Color currentColor = Theme.of(context).colorScheme.primary;
    Color answeredColor = Theme.of(context).colorScheme.secondary;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth < 420 ? 4 : 5;

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Tổng quan câu hỏi',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '$title • $unanswered câu chưa trả lời',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        legendDot(currentColor),
                        const SizedBox(width: 6),
                        const Text('Đang làm'),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        legendDot(answeredColor.withValues(alpha: 0.35)),
                        const SizedBox(width: 6),
                        const Text('Đã trả lời'),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        legendDot(Theme.of(context).colorScheme.surfaceContainerHighest),
                        const SizedBox(width: 6),
                        const Text('Chưa trả lời'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.15,
                    ),
                    itemCount: total,
                    itemBuilder: (context, i) {
                      final qId = qIds[i];
                      final isCurrent = i == currentIndex;
                      final isAnswered = answeredQIds.contains(qId);

                      Color bg;
                      Color fg;
                      Color border;

                      if (isCurrent) {
                        bg = Theme.of(context).colorScheme.primary;
                        fg = Theme.of(context).colorScheme.onPrimary;
                        border = Theme.of(context).colorScheme.primary;
                      } else if (isAnswered) {
                        bg = Theme.of(context)
                            .colorScheme
                            .secondaryContainer
                            .withValues(alpha: 0.9);
                        fg = Theme.of(context).colorScheme.onSecondaryContainer;
                        border = Theme.of(context).colorScheme.secondary;
                      } else {
                        bg = Theme.of(context).colorScheme.surfaceContainerHighest;
                        fg = Theme.of(context).colorScheme.onSurface;
                        border = Theme.of(context).dividerColor;
                      }

                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => onJump(i),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: border),
                          ),
                          child: Text(
                            '${i + 1}',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: fg,
                                ),
                          ),
                        ).animate().fadeIn(duration: 180.ms, delay: (15 * i).ms),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: unanswered > 0 ? onJumpFirstUnanswered : null,
                        icon: const Icon(Icons.flag_outlined),
                        label: const Text('Tới câu chưa làm'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Đóng'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QuizScreenLifecycle extends StatefulWidget {
  const _QuizScreenLifecycle({required this.child, required this.onResume});

  final Widget child;
  final VoidCallback onResume;

  @override
  State<_QuizScreenLifecycle> createState() => _QuizScreenLifecycleState();
}

class _QuizScreenLifecycleState extends State<_QuizScreenLifecycle>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.onResume();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
