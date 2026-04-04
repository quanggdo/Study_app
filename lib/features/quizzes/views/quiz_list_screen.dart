import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/quiz_viewmodel.dart';

class QuizListScreen extends ConsumerWidget {
  const QuizListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(quizRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Trắc nghiệm')),
      body: StreamBuilder(
        stream: repo.watchQuizzes(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Lỗi: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final quizzes = snap.data!;
          if (quizzes.isEmpty) {
            return const Center(child: Text('Chưa có quiz nào.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: quizzes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final q = quizzes[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.quiz_rounded),
                  title: Text(q.title),
                  subtitle: Text(
                    [
                      if ((q.category ?? '').trim().isNotEmpty) q.category!,
                      if ((q.author ?? '').trim().isNotEmpty) 'Tác giả: ${q.author}',
                      if (q.timeLimit != null) 'Thời gian: ${q.timeLimit}p',
                      'Số câu: ${q.questions.length}',
                    ].join(' • '),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/quiz/${q.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

