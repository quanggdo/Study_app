import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/flashcard_deck.dart';
import 'deck_detail_screen.dart';

class _DeckListItem {
  const _DeckListItem({
    required this.deck,
    required this.category,
  });

  final FlashcardDeck deck;
  final String category;

  bool matches(String keyword) {
    if (keyword.isEmpty) return true;
    final k = keyword.toLowerCase();
    return deck.title.toLowerCase().contains(k) || category.toLowerCase().contains(k);
  }
}

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen> {
  static const int _pageSize = 10;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_DeckListItem> _items = <_DeckListItem>[];
  DocumentSnapshot<Map<String, dynamic>>? _lastDoc;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;
  String _keyword = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMore();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _loading) return;
    if (!_scrollController.hasClients) return;

    final remaining = _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    if (remaining < 220) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('flashcards')
          .orderBy(FieldPath.documentId)
          .limit(_pageSize);

      final cursor = _lastDoc;
      if (cursor != null) {
        query = query.startAfterDocument(cursor);
      }

      final snap = await query.get();
      final page = snap.docs.map(_mapDeckDoc).toList();

      setState(() {
        _items.addAll(page);
        if (snap.docs.isNotEmpty) {
          _lastDoc = snap.docs.last;
        }
        _hasMore = snap.docs.length == _pageSize;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  _DeckListItem _mapDeckDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};

    final title = (data['title'] ?? '').toString().trim();
    final description = (data['description'] ?? '').toString().trim();
    final category = (data['category'] ?? '').toString().trim();

    final tagsRaw = data['tags'];
    final tags = tagsRaw is List
        ? tagsRaw.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList()
        : const <String>[];

    final cardsRaw = data['cards'];
    final cardCount = cardsRaw is List ? cardsRaw.length : 0;

    final now = DateTime.now();
    final deck = FlashcardDeck(
      id: doc.id,
      uId: '',
      title: title.isEmpty ? 'Deck ${doc.id}' : title,
      description: description.isEmpty ? null : description,
      tags: tags,
      cardCount: cardCount,
      createdAt: now,
      updatedAt: now,
    );

    return _DeckListItem(
      deck: deck,
      category: category,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _items.where((e) => e.matches(_keyword)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        actions: const [],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo title hoặc category',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _keyword.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _keyword = '';
                          });
                        },
                      ),
              ),
              onChanged: (value) {
                setState(() {
                  _keyword = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _items.clear();
                  _lastDoc = null;
                  _hasMore = true;
                  _error = null;
                });
                await _loadMore();
              },
              child: _buildList(filtered),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<_DeckListItem> filtered) {
    if (_items.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty && _error != null) {
      return Center(child: Text('Lỗi: $_error'));
    }

    if (filtered.isEmpty) {
      return ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 80),
          Center(child: Text('Không có bộ thẻ phù hợp.')),
        ],
      );
    }

    final itemCount = filtered.length + (_loading ? 1 : 0);
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= filtered.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final item = filtered[index];
        final deck = item.deck;
        final subtitleParts = <String>[
          '${deck.cardCount} thẻ',
        ];
        if (item.category.trim().isNotEmpty) {
          subtitleParts.add('Category: ${item.category}');
        }

        return Card(
          child: ListTile(
            title: Text(deck.title),
            subtitle: Text(subtitleParts.join(' • ')),
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
  }
}
