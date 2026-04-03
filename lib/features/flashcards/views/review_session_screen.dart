import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                            ),
                        ],
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
        Text('Còn $remaining thẻ đến hạn'),
        const Spacer(),
        Text('Thẻ ${min(index + 1, max(1, total))}/$total'),
      ],
    );
  }
}

class _GradeBar extends StatelessWidget {
  const _GradeBar({required this.onGrade});

  final Future<void> Function(ReviewGrade grade) onGrade;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => onGrade(ReviewGrade.again),
            child: const Text('Again'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () => onGrade(ReviewGrade.hard),
            child: const Text('Hard'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton(
            onPressed: () => onGrade(ReviewGrade.good),
            child: const Text('Good'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton.tonal(
            onPressed: () => onGrade(ReviewGrade.easy),
            child: const Text('Easy'),
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
