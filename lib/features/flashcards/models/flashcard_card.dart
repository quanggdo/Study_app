import 'package:freezed_annotation/freezed_annotation.dart';

part 'flashcard_card.freezed.dart';
part 'flashcard_card.g.dart';

@freezed
class FlashcardCard with _$FlashcardCard {
  const factory FlashcardCard({
    required String id,
    required String deckId,
    required String uId,
    required String front,
    required String back,
    String? hint,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isDeleted,
  }) = _FlashcardCard;

  factory FlashcardCard.fromJson(Map<String, Object?> json) =>
      _$FlashcardCardFromJson(json);
}

