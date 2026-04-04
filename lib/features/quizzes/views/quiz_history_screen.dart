import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/quiz_result_model.dart';
import '../viewmodels/quiz_viewmodel.dart';

class QuizHistoryScreen extends ConsumerWidget {
  const QuizHistoryScreen({super.key, this.quizId});

  final String? quizId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(quizHistoryProvider(quizId));

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử làm bài')),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Chưa có lịch sử.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final attempt = items[i];
              return _AttemptCard(
                attempt: attempt,
                onOpen: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => QuizAttemptReviewScreen(attempt: attempt),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class QuizLastAttemptScreen extends ConsumerWidget {
  const QuizLastAttemptScreen({super.key, required this.quizId});

  final String quizId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastAttempt = ref.watch(lastQuizAttemptProvider(quizId));

    return Scaffold(
      appBar: AppBar(title: const Text('Bài làm gần nhất')),
      body: lastAttempt.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (attempt) {
          if (attempt == null) {
            return const Center(child: Text('Chưa có bài làm.'));
          }
          return QuizAttemptReviewScreen(
            attempt: attempt,
            showAppBar: false,
          );
        },
      ),
    );
  }
}

class QuizAttemptReviewScreen extends ConsumerWidget {
  const QuizAttemptReviewScreen({
    super.key,
    required this.attempt,
    this.showAppBar = true,
  });

  final QuizAttempt attempt;
  final bool showAppBar;

  String _formatDuration(int? seconds) {
    if (seconds == null) return '-';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }

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
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(quizRepositoryProvider);
    final review = attempt.review;

    return StreamBuilder(
      stream: repo.watchQuiz(attempt.quizId),
      builder: (context, snap) {
        final quiz = snap.data;
        final questions = quiz?.questions ?? const [];
        final byId = {
          for (final q in questions) q.qId: q,
        };

        return Scaffold(
          appBar: showAppBar ? AppBar(title: const Text('Review bài làm')) : null,
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ScoreCard(attempt: attempt, durationText: _formatDuration(attempt.durationSeconds)),
                const SizedBox(height: 12),
                if (snap.hasError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Không tải được đề. Hiển thị theo qId.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    itemCount: review.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final item = review[i];
                      final q = byId[item.qId] ?? (i < questions.length ? questions[i] : null);
                      final qRaw = (q?.question ?? '').toString().trim();
                      final qTitle = qRaw.isNotEmpty ? qRaw : 'Câu ${i + 1} • ${item.qId}';
                      final choices = q?.choices ?? const [];

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    item.isCorrect
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: item.isCorrect
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.error,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(qTitle)),
                                  Text(
                                    item.isCorrect ? 'Đúng' : 'Sai',
                                    style: Theme.of(context).textTheme.labelLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (choices.isNotEmpty)
                                ...choices.map((c) {
                                  final isUserChoice =
                                      item.userChoice == c.id &&
                                          item.userChoice.isNotEmpty;
                                  final isCorrectChoice =
                                      item.correctChoice == c.id &&
                                          item.correctChoice.isNotEmpty;

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
                                            c.id,
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
                                        Expanded(child: Text(c.text)),
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
                                })
                              else
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Bạn chọn: ${item.userChoice.isEmpty ? '-' : item.userChoice}',
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Đáp án đúng: ${item.correctChoice.isEmpty ? '-' : item.correctChoice}',
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AttemptCard extends StatelessWidget {
  const _AttemptCard({required this.attempt, required this.onOpen});

  final QuizAttempt attempt;
  final VoidCallback onOpen;

  String _formatScore10(double value) {
    final v = value.isNaN ? 0 : value;
    return v.toStringAsFixed(1);
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return '-';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final completedAt = attempt.completedAt;
    final timeText = completedAt == null
        ? 'Không rõ thời gian'
        : DateFormat('dd/MM/yyyy HH:mm').format(completedAt);

    return Card(
      child: ListTile(
        leading: const Icon(Icons.history_rounded),
        title: Text(attempt.quizTitle),
        subtitle: Text(
          'Điểm: ${attempt.score}/${attempt.total} • ${_formatScore10(attempt.score10)}/10 • ${_formatDuration(attempt.durationSeconds)} • $timeText',
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onOpen,
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.attempt, required this.durationText});

  final QuizAttempt attempt;
  final String durationText;

  String _formatScore10(double value) {
    final v = value.isNaN ? 0 : value;
    return v.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              '${attempt.score}/${attempt.total}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Điểm: ${_formatScore10(attempt.score10)}/10',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              durationText,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}
