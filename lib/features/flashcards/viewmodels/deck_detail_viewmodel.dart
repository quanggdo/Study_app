import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/viewmodels/auth_viewmodel.dart';
import '../models/flashcard_card.dart';
import '../repositories/flashcard_repository.dart';

final flashcardCardsProvider = StreamProvider.autoDispose
    .family<List<FlashcardCard>, String>((ref, deckId) {
  final authState = ref.watch(authNotifierProvider);
  final uId = authState.user?.uid;
  if (uId == null) {
    return const Stream.empty();
  }

  final repo = ref.watch(flashcardRepositoryProvider);
  return repo.watchCards(uId: uId, deckId: deckId);
});

