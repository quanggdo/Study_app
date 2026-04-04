import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/create_card_viewmodel.dart';

class CreateCardScreen extends ConsumerStatefulWidget {
  const CreateCardScreen({
    super.key,
    required this.deckId,
  });

  final String deckId;

  @override
  ConsumerState<CreateCardScreen> createState() => _CreateCardScreenState();
}

class _CreateCardScreenState extends ConsumerState<CreateCardScreen> {
  final _frontController = TextEditingController();
  final _backController = TextEditingController();
  final _hintController = TextEditingController();

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vmState = ref.watch(createCardViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm thẻ'),
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
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _backController,
                decoration: const InputDecoration(labelText: 'Back'),
                maxLines: 3,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _hintController,
                decoration: const InputDecoration(labelText: 'Hint (tuỳ chọn)'),
                maxLines: 2,
                textInputAction: TextInputAction.done,
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
                              .read(createCardViewModelProvider.notifier)
                              .create(
                                deckId: widget.deckId,
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
                      : const Text('Thêm'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
