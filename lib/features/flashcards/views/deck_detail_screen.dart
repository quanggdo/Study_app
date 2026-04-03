import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/flashcard_deck.dart';
import '../viewmodels/deck_detail_viewmodel.dart';
import 'create_card_screen.dart';

class DeckDetailScreen extends ConsumerWidget {
  const DeckDetailScreen({
    super.key,
    required this.deck,
  });

  final FlashcardDeck deck;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(flashcardCardsProvider(deck.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(deck.title),
        actions: [
          IconButton(
            tooltip: 'Thêm thẻ',
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreateCardScreen(deckId: deck.id),
                ),
              );
            },
          ),
        ],
      ),
      body: cardsAsync.when(
        data: (cards) {
          if (cards.isEmpty) {
            return const Center(
              child: Text('Deck này chưa có thẻ nào. Hãy thêm thẻ!'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cards.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final card = cards[index];
              return Card(
                child: ListTile(
                  title: Text(card.front, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(card.back, maxLines: 2, overflow: TextOverflow.ellipsis),
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

