import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_state.freezed.dart';
part 'review_state.g.dart';

@freezed
class ReviewState with _$ReviewState {
  const factory ReviewState({
    required String cardId,
    required String deckId,
    required String uId,
    required DateTime dueAt,
    @Default(0) int reps,
    @Default(0) int lapses,
    @Default(0) int intervalDays,
    @Default(2.5) double easeFactor,
    DateTime? lastReviewedAt,
    required DateTime updatedAt,
    @Default(false) bool isDeleted,
  }) = _ReviewState;

  factory ReviewState.fromJson(Map<String, Object?> json) =>
      _$ReviewStateFromJson(json);
}

