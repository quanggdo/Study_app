import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'quiz_history_screen.dart';

class QuizEntryScreen extends StatelessWidget {
  const QuizEntryScreen({
    super.key,
    required this.quizId,
    required this.title,
  });

  final String quizId;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Chọn hành động cho bài quiz này.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.push('/quiz/$quizId'),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Làm bài ngay'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => QuizHistoryScreen(quizId: quizId),
                  ),
                );
              },
              icon: const Icon(Icons.history_rounded),
              label: const Text('Xem lịch sử làm bài'),
            ),
          ],
        ),
      ),
    );
  }
}
