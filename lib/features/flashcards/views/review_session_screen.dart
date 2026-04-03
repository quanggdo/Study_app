import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/review_state.dart';
import '../viewmodels/review_session_viewmodel.dart';

class ReviewSessionScreen extends ConsumerWidget {
  const ReviewSessionScreen({
    super.key,
    required this.deckId,
    required this.deckTitle,
  });

  final String deckId;
  final String deckTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(reviewSessionProvider(deckId));
    final vm = ref.read(reviewSessionProvider(deckId).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ôn tập • $deckTitle'),
      ),
      body: session.loading
          ? const Center(child: CircularProgressIndicator())
          : session.error != null
              ? Center(child: Text('Lỗi: ${session.error}'))
              : session.current == null
                  ? _DoneView(total: session.total)
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ProgressHeader(
                            index: session.index,
                            total: session.total,
                            remaining: session.items.length,
                          ),
                          if (session.lastScheduledMessage != null) ...[
                            const SizedBox(height: 8),
                            _ScheduleHint(message: session.lastScheduledMessage!),
                          ],
                          const SizedBox(height: 12),
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _CardModeBadge(state: session.current!.state),
                                      const SizedBox(height: 8),
                                      Text(
                                        session.current!.card.front,
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                      const SizedBox(height: 16),
                                      if (session.showAnswer) ...[
                                        const Divider(),
                                        const SizedBox(height: 12),
                                        Text(
                                          session.current!.card.back,
                                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                        if (session.current!.card.hint != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 12),
                                            child: Text(
                                              'Gợi ý: ${session.current!.card.hint}',
                                              style: Theme.of(context).textTheme.bodySmall,
                                            ),
                                          ),
                                      ] else ...[
                                        Text(
                                          'Nhấn “Hiện đáp án” để xem mặt sau.',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (!session.showAnswer)
                            FilledButton(
                              onPressed: vm.revealAnswer,
                              child: const Text('Hiện đáp án'),
                            )
                          else
                            _GradeBar(
                              onGrade: vm.grade,
                              preview: vm.previewNextState,
                            ),
                        ],
                      ),
                    ),
    );
  }
}

class _CardModeBadge extends StatelessWidget {
  const _CardModeBadge({required this.state});

  final ReviewState? state;

  bool get _isLearning {
    final s = state;
    if (s == null) return true;
    return s.reps < 2 || s.intervalDays <= 0;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLearning = _isLearning;

    final bg = isLearning ? cs.tertiaryContainer : cs.secondaryContainer;
    final fg = isLearning ? cs.onTertiaryContainer : cs.onSecondaryContainer;
    final label = isLearning ? 'Learning' : 'Review';

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg),
        ),
      ),
    );
  }
}

class _ScheduleHint extends StatelessWidget {
  const _ScheduleHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onPrimaryContainer,
            ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.index,
    required this.total,
    required this.remaining,
  });

  final int index;
  final int total;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Đến hạn: $remaining thẻ'),
        const Spacer(),
        Text('Tiến độ: ${min(index + 1, max(1, total))}/$total'),
      ],
    );
  }
}

class _GradeBar extends StatelessWidget {
  const _GradeBar({required this.onGrade, required this.preview});

  final Future<void> Function(ReviewGrade grade) onGrade;
  final Future<ReviewState?> Function(ReviewGrade grade) preview;

  static String _formatEta(Duration diff) {
    final clamped = diff.isNegative ? Duration.zero : diff;

    if (clamped.inMinutes < 60) {
      final m = clamped.inMinutes.clamp(0, 999999);
      return '${m}m';
    }
    if (clamped.inHours < 24) {
      return '${clamped.inHours}h';
    }
    if (clamped.inDays < 30) {
      return '${clamped.inDays}d';
    }

    final months = (clamped.inDays / 30).round();
    if (months < 12) return '${months}mo';

    final years = (clamped.inDays / 365).round();
    return '${years}y';
  }

  Color _bgFor(BuildContext context, ReviewGrade grade) {
    switch (grade) {
      case ReviewGrade.again:
        return Colors.red.withValues(alpha: 0.12);
      case ReviewGrade.hard:
        return Colors.orange.withValues(alpha: 0.18);
      case ReviewGrade.good:
        return Colors.green.withValues(alpha: 0.18);
      case ReviewGrade.easy:
        return Colors.blue.withValues(alpha: 0.16);
    }
  }

  Color _fgFor(BuildContext context, ReviewGrade grade) {
    switch (grade) {
      case ReviewGrade.again:
        return Colors.red.shade800;
      case ReviewGrade.hard:
        return Colors.orange.shade900;
      case ReviewGrade.good:
        return Colors.green.shade900;
      case ReviewGrade.easy:
        return Colors.blue.shade900;
    }
  }

  Widget _gradeButton({
    required BuildContext context,
    required ReviewGrade grade,
    required String label,
  }) {
    final now = DateTime.now();

    return FutureBuilder<ReviewState?>(
      future: preview(grade),
      builder: (context, snap) {
        final next = snap.data;
        final eta = next == null ? null : _formatEta(next.dueAt.difference(now));
        final enabled = next != null && (snap.connectionState != ConnectionState.waiting);

        final bg = _bgFor(context, grade);
        final fg = _fgFor(context, grade);

        return SizedBox(
          height: 52,
          child: InkWell(
            onTap: enabled ? () => onGrade(grade) : null,
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              decoration: BoxDecoration(
                color: enabled ? bg : Theme.of(context).disabledColor.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: enabled ? fg.withValues(alpha: 0.25) : Colors.transparent,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: enabled ? fg : Theme.of(context).disabledColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      eta ?? '…',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: enabled ? fg.withValues(alpha: 0.85) : Theme.of(context).disabledColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _gradeButton(
            context: context,
            grade: ReviewGrade.again,
            label: 'Again',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _gradeButton(
            context: context,
            grade: ReviewGrade.hard,
            label: 'Hard',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _gradeButton(
            context: context,
            grade: ReviewGrade.good,
            label: 'Good',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _gradeButton(
            context: context,
            grade: ReviewGrade.easy,
            label: 'Easy',
          ),
        ),
      ],
    );
  }
}

class _DoneView extends StatelessWidget {
  const _DoneView({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hoàn thành phiên ôn tập!',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text('Bạn đã ôn $total thẻ.'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }
}
