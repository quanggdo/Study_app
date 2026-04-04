import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/viewmodels/auth_viewmodel.dart';
import '../repositories/flashcard_repository.dart';

class CreateDeckState {
  const CreateDeckState({
    this.isSubmitting = false,
    this.errorMessage,
  });

  final bool isSubmitting;
  final String? errorMessage;

  CreateDeckState copyWith({
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return CreateDeckState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class CreateDeckViewModel extends AutoDisposeNotifier<CreateDeckState> {
  @override
  CreateDeckState build() => const CreateDeckState();

  Future<bool> create({
    required String title,
    String? description,
  }) async {
    final uId = ref.read(authNotifierProvider).user?.uid;
    if (uId == null) {
      state = state.copyWith(errorMessage: 'Bạn chưa đăng nhập');
      return false;
    }

    final t = title.trim();
    if (t.isEmpty) {
      state = state.copyWith(errorMessage: 'Vui lòng nhập tiêu đề');
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      await ref.read(flashcardRepositoryProvider).createDeck(
            uId: uId,
            title: t,
            description: description,
          );
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }
}

final createDeckViewModelProvider =
    AutoDisposeNotifierProvider<CreateDeckViewModel, CreateDeckState>(
  CreateDeckViewModel.new,
);

