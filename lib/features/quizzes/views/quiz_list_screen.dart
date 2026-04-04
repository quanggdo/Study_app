import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'quiz_entry_screen.dart';

class _QuizListItem {
  const _QuizListItem({
    required this.id,
    required this.title,
    required this.category,
    required this.author,
    required this.timeLimit,
    required this.questionCount,
  });

  final String id;
  final String title;
  final String? category;
  final String? author;
  final int? timeLimit;
  final int questionCount;

  bool matches(String keyword) {
    if (keyword.isEmpty) return true;
    final k = keyword.toLowerCase();
    return title.toLowerCase().contains(k) ||
        (category ?? '').toLowerCase().contains(k);
  }
}

class QuizListScreen extends ConsumerStatefulWidget {
  const QuizListScreen({super.key});

  @override
  ConsumerState<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends ConsumerState<QuizListScreen> {
  static const int _pageSize = 12;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_QuizListItem> _items = <_QuizListItem>[];
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
          .collection('quiz')
          .orderBy(FieldPath.documentId)
          .limit(_pageSize);

      final cursor = _lastDoc;
      if (cursor != null) {
        query = query.startAfterDocument(cursor);
      }

      final snap = await query.get();

      final page = snap.docs.map(_mapQuizDoc).toList();

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

  _QuizListItem _mapQuizDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final title = (data['title'] ?? '').toString().trim();
    final category = (data['category'] ?? '').toString().trim();
    final author = (data['author'] ?? '').toString().trim();

    final rawTimeLimit = data['timeLimit'] ??
        data['time_limit'] ??
        data['duration'] ??
        data['duration_minutes'];
    int? timeLimit;
    if (rawTimeLimit is num) {
      timeLimit = rawTimeLimit.toInt();
    } else if (rawTimeLimit is String) {
      timeLimit = int.tryParse(rawTimeLimit.trim());
    }

    final questions = data['questions'];
    final questionCount = questions is List ? questions.length : 0;

    return _QuizListItem(
      id: doc.id,
      title: title.isEmpty ? 'Quiz ${doc.id}' : title,
      category: category.isEmpty ? null : category,
      author: author.isEmpty ? null : author,
      timeLimit: timeLimit,
      questionCount: questionCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _items.where((e) => e.matches(_keyword)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Trắc nghiệm')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo tiêu đề hoặc category',
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
              child: _buildList(context, filtered),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<_QuizListItem> filtered) {
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
          Center(child: Text('Không có quiz phù hợp.')),
        ],
      );
    }

    final itemCount = filtered.length + (_loading ? 1 : 0);
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        if (i >= filtered.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final q = filtered[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.quiz_rounded),
            title: Text(q.title),
            subtitle: Text(
              [
                if ((q.category ?? '').trim().isNotEmpty) q.category!,
                if ((q.author ?? '').trim().isNotEmpty) 'Tác giả: ${q.author}',
                if (q.timeLimit != null) 'Thời gian: ${q.timeLimit}p',
                'Số câu: ${q.questionCount}',
              ].join(' • '),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => QuizEntryScreen(
                    quizId: q.id,
                    title: q.title,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

