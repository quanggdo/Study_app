import 'package:freezed_annotation/freezed_annotation.dart';

part 'flashcard_deck.freezed.dart';
part 'flashcard_deck.g.dart';

@freezed
class FlashcardDeck with _$FlashcardDeck {
  const factory FlashcardDeck({
    required String id,
    required String uId,
    required String title,
    String? description,
    @Default(<String>[]) List<String> tags,
    @Default(0) int cardCount,
    DateTime? lastStudiedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isDeleted,
  }) = _FlashcardDeck;

  factory FlashcardDeck.fromJson(Map<String, Object?> json) =>
      _$FlashcardDeckFromJson(json);
}

