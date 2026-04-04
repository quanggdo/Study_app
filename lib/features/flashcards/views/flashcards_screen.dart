import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/flashcard_deck_list_viewmodel.dart';
import 'deck_detail_screen.dart';

class FlashcardsScreen extends ConsumerWidget {
  const FlashcardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decksAsync = ref.watch(flashcardDecksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        actions: const [],
      ),
      body: decksAsync.when(
        data: (decks) {
          if (decks.isEmpty) {
            return const Center(
              child: Text('Chưa có bộ thẻ nào trong Firestore.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: decks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final deck = decks[index];
              return Card(
                child: ListTile(
                  title: Text(deck.title),
                  subtitle: Text('${deck.cardCount} thẻ'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DeckDetailScreen(deck: deck),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
