import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/create_deck_viewmodel.dart';

class CreateDeckScreen extends ConsumerStatefulWidget {
  const CreateDeckScreen({super.key});

  @override
  ConsumerState<CreateDeckScreen> createState() => _CreateDeckScreenState();
}

class _CreateDeckScreenState extends ConsumerState<CreateDeckScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vmState = ref.watch(createDeckViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo bộ thẻ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Mô tả (tuỳ chọn)',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            if (vmState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  vmState.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: vmState.isSubmitting
                    ? null
                    : () async {
                        final ok = await ref
                            .read(createDeckViewModelProvider.notifier)
                            .create(
                              title: _titleController.text,
                              description: _descriptionController.text,
                            );
                        if (!context.mounted) return;
                        if (ok) Navigator.of(context).pop();
                      },
                child: vmState.isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Tạo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

