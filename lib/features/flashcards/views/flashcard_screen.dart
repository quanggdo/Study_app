// Placeholder for flashcards/views/flashcard_screen.dart

// Backwards-compat shim: dự án trước đó có thể import FlashcardScreen.

import 'package:flutter/widgets.dart';

import 'flashcards_screen.dart';

@Deprecated('Dùng FlashcardsScreen thay cho FlashcardScreen')
typedef FlashcardScreen = FlashcardsScreen;

@Deprecated('Dùng FlashcardsScreen thay cho FlashcardScreen')
class FlashcardScreenShim extends StatelessWidget {
  const FlashcardScreenShim({super.key});

  @override
  Widget build(BuildContext context) => const FlashcardsScreen();
}
