import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/viewmodels/auth_viewmodel.dart';
import '../models/flashcard_card.dart';
import '../repositories/flashcard_repository.dart';

class EditCardState {
  const EditCardState({
    this.isSubmitting = false,
    this.errorMessage,
  });

  final bool isSubmitting;
  final String? errorMessage;

  EditCardState copyWith({
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return EditCardState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class EditCardViewModel extends AutoDisposeNotifier<EditCardState> {
  @override
  EditCardState build() => const EditCardState();

  Future<bool> save({
    required FlashcardCard card,
    required String front,
    required String back,
    String? hint,
  }) async {
    final uId = ref.read(authNotifierProvider).user?.uid;
    if (uId == null) {
      state = state.copyWith(errorMessage: 'Bạn chưa đăng nhập');
      return false;
    }

    final f = front.trim();
    final b = back.trim();
    if (f.isEmpty || b.isEmpty) {
      state = state.copyWith(errorMessage: 'Vui lòng nhập Front và Back');
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await ref.read(flashcardRepositoryProvider).updateCard(
            uId: uId,
            card: card.copyWith(
              front: f,
              back: b,
              hint: hint?.trim().isEmpty == true ? null : hint,
            ),
          );
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> delete(FlashcardCard card) async {
    final uId = ref.read(authNotifierProvider).user?.uid;
    if (uId == null) {
      state = state.copyWith(errorMessage: 'Bạn chưa đăng nhập');
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await ref.read(flashcardRepositoryProvider).deleteCard(uId: uId, card: card);
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }
}

final editCardViewModelProvider =
    AutoDisposeNotifierProvider<EditCardViewModel, EditCardState>(
  EditCardViewModel.new,
);

