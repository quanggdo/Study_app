import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/flashcards/data/local/flashcard_card_entity.dart';
import '../../features/flashcards/data/local/flashcard_deck_entity.dart';
import '../../features/flashcards/data/local/review_state_entity.dart';

/// Central place to open/keep the Isar instance.
///
/// Hiện tại chỉ đăng ký schemas cho Flashcards. Khi mở rộng, thêm schema vào đây.
class IsarService {
  IsarService._(this.isar);

  final Isar isar;

  static Future<IsarService> open() async {
    final dir = await getApplicationDocumentsDirectory();

    final isar = await Isar.open(
      [
        FlashcardDeckEntitySchema,
        FlashcardCardEntitySchema,
        ReviewStateEntitySchema,
      ],
      directory: dir.path,
    );

    return IsarService._(isar);
  }
}

final isarServiceProvider = Provider<IsarService>((ref) {
  throw UnimplementedError(
    'isarServiceProvider must be overridden in main() after opening Isar',
  );
});

