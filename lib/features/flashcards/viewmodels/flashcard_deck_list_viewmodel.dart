import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/viewmodels/auth_viewmodel.dart';
import '../models/flashcard_deck.dart';
import '../repositories/flashcard_repository.dart';

final flashcardDecksProvider = StreamProvider.autoDispose<List<FlashcardDeck>>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final uId = authState.user?.uid;
  if (uId == null) {
    return const Stream.empty();
  }

  final repo = ref.watch(flashcardRepositoryProvider);
  return repo.watchDecks(uId: uId);
});
