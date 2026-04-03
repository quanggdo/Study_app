import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/viewmodels/auth_viewmodel.dart';
import '../repositories/flashcard_repository.dart';

class CreateCardState {
  const CreateCardState({
    this.isSubmitting = false,
    this.errorMessage,
  });

  final bool isSubmitting;
  final String? errorMessage;

  CreateCardState copyWith({
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return CreateCardState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class CreateCardViewModel extends AutoDisposeNotifier<CreateCardState> {
  @override
  CreateCardState build() => const CreateCardState();

  Future<bool> create({
    required String deckId,
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
      await ref.read(flashcardRepositoryProvider).createCard(
            uId: uId,
            deckId: deckId,
            front: f,
            back: b,
            hint: hint,
          );
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }
}

final createCardViewModelProvider =
    AutoDisposeNotifierProvider<CreateCardViewModel, CreateCardState>(
  CreateCardViewModel.new,
);

