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
    this.includeAllCards = false,
  });

  final String deckId;
  final String deckTitle;
  final bool includeAllCards;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = ReviewSessionParams(
      deckId: deckId,
      includeAllCards: includeAllCards,
    );
    final session = ref.watch(reviewSessionProvider(params));
    final vm = ref.read(reviewSessionProvider(params).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          includeAllCards
              ? 'Ôn tất cả • $deckTitle'
              : 'Ôn đến hạn • $deckTitle',
        ),
      ),
      body: session.loading
          ? const Center(child: CircularProgressIndicator())
          : session.error != null
              ? Center(child: Text('Lỗi: ${session.error}'))
              : session.current == null
                  ? _DoneView(reviewed: session.reviewedCount, total: session.total)
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ProgressHeader(
                            reviewed: session.reviewedCount,
                            total: session.total,
                            remaining: session.remaining,
                          ),
                          if (session.lastScheduledMessage != null) ...[
                            const SizedBox(height: 8),
                            _ScheduleHint(message: session.lastScheduledMessage!),
                          ],
                          const SizedBox(height: 12),
                          Expanded(
                            child: _FlipCard(
                              showBack: session.showAnswer,
                              onToggle: vm.toggleAnswer,
                              frontChild: _CardFace(
                                badge: _CardModeBadge(state: session.current!.state),
                                title: session.current!.card.front,
                                body: session.current!.card.front,
                                hint: null,
                                isBack: false,
                              ),
                              backChild: _CardFace(
                                badge: _CardModeBadge(state: session.current!.state),
                                title: session.current!.card.front,
                                body: session.current!.card.back,
                                hint: session.current!.card.hint,
                                isBack: true,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (!session.showAnswer)
                            Text(
                              'Chạm vào thẻ để lật và xem đáp án.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
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
    required this.reviewed,
    required this.total,
    required this.remaining,
  });

  final int reviewed;
  final int total;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Đến hạn: $remaining thẻ'),
        const Spacer(),
        Text('Đã chấm: $reviewed/$total'),
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
  const _DoneView({required this.reviewed, required this.total});

  final int reviewed;
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
            Text('Bạn đã ôn $reviewed/$total thẻ.'),
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

class _FlipCard extends StatelessWidget {
  const _FlipCard({
    required this.showBack,
    required this.onToggle,
    required this.frontChild,
    required this.backChild,
  });

  final bool showBack;
  final VoidCallback onToggle;
  final Widget frontChild;
  final Widget backChild;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          final rotate = Tween<double>(begin: pi, end: 0).animate(animation);
          return AnimatedBuilder(
            animation: rotate,
            child: child,
            builder: (context, child) {
              final isUnder = (ValueKey(showBack) != child?.key);
              var tilt = (animation.value - 0.5).abs() - 0.5;
              tilt *= isUnder ? -0.003 : 0.003;

              final value = isUnder ? min(rotate.value, pi / 2) : rotate.value;
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(value)
                  ..setEntry(3, 0, tilt),
                alignment: Alignment.center,
                child: child,
              );
            },
          );
        },
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        child: showBack
            ? KeyedSubtree(
                key: const ValueKey(true),
                child: backChild,
              )
            : KeyedSubtree(
                key: const ValueKey(false),
                child: frontChild,
              ),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.badge,
    required this.title,
    required this.body,
    required this.hint,
    required this.isBack,
  });

  final Widget badge;
  final String title;
  final String body;
  final String? hint;
  final bool isBack;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              badge,
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (isBack) ...[
                const Divider(),
                const SizedBox(height: 12),
              ],
              Text(
                body,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (hint != null && hint!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Gợi ý: $hint',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
