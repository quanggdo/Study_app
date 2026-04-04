import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/flashcard_deck.dart';
import '../viewmodels/deck_detail_viewmodel.dart';
import 'review_session_screen.dart';

class DeckDetailScreen extends ConsumerWidget {
  const DeckDetailScreen({
    super.key,
    required this.deck,
  });

  final FlashcardDeck deck;

  Future<bool?> _showReviewModePicker(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.schedule_rounded),
                  title: const Text('Ôn thẻ đến hạn'),
                  subtitle: const Text('Chỉ học các thẻ đến hạn theo lịch SM2'),
                  onTap: () => Navigator.pop(ctx, false),
                ),
                ListTile(
                  leading: const Icon(Icons.library_books_rounded),
                  title: const Text('Ôn tất cả thẻ'),
                  subtitle: const Text('Luyện toàn bộ thẻ trong bộ hiện tại'),
                  onTap: () => Navigator.pop(ctx, true),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(flashcardCardsProvider(deck.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(deck.title),
        actions: [
          IconButton(
            tooltip: 'Ôn tập',
            icon: const Icon(Icons.play_circle_fill_rounded),
            onPressed: () async {
              final includeAll = await _showReviewModePicker(context);
              if (includeAll == null || !context.mounted) return;

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ReviewSessionScreen(
                    deckId: deck.id,
                    deckTitle: deck.title,
                    includeAllCards: includeAll,
                  ),
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
