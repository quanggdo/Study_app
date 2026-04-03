import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/flashcard_card.dart';
import '../viewmodels/edit_card_viewmodel.dart';

class EditCardScreen extends ConsumerStatefulWidget {
  const EditCardScreen({
    super.key,
    required this.card,
  });

  final FlashcardCard card;

  @override
  ConsumerState<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends ConsumerState<EditCardScreen> {
  late final TextEditingController _frontController;
  late final TextEditingController _backController;
  late final TextEditingController _hintController;

  @override
  void initState() {
    super.initState();
    _frontController = TextEditingController(text: widget.card.front);
    _backController = TextEditingController(text: widget.card.back);
    _hintController = TextEditingController(text: widget.card.hint ?? '');
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vmState = ref.watch(editCardViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa thẻ'),
        actions: [
          IconButton(
            tooltip: 'Xoá thẻ',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: vmState.isSubmitting
                ? null
                : () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Xoá thẻ?'),
                          content: const Text('Thẻ sẽ bị xoá (ẩn đi) khỏi deck.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Huỷ'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Xoá'),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirm != true) return;

                    final ok = await ref
                        .read(editCardViewModelProvider.notifier)
                        .delete(widget.card);
                    if (!context.mounted) return;
                    if (ok) Navigator.of(context).pop();
                  },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _frontController,
                decoration: const InputDecoration(labelText: 'Front'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _backController,
                decoration: const InputDecoration(labelText: 'Back'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _hintController,
                decoration: const InputDecoration(labelText: 'Hint (tuỳ chọn)'),
                maxLines: 2,
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
                              .read(editCardViewModelProvider.notifier)
                              .save(
                                card: widget.card,
                                front: _frontController.text,
                                back: _backController.text,
                                hint: _hintController.text,
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
                      : const Text('Lưu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

