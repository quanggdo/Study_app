import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz_result_model.freezed.dart';
part 'quiz_result_model.g.dart';

@freezed
class UserAnswer with _$UserAnswer {
  const factory UserAnswer({
    @JsonKey(name: 'q_id') required String qId,
    @JsonKey(name: 'user_choice') required String userChoice,
  }) = _UserAnswer;

  factory UserAnswer.fromJson(Map<String, Object?> json) =>
      _$UserAnswerFromJson(json);
}

@freezed
class QuizReviewItem with _$QuizReviewItem {
  const factory QuizReviewItem({
    @JsonKey(name: 'q_id') required String qId,
    @JsonKey(name: 'user_choice') required String userChoice,
    @JsonKey(name: 'correct_choice') required String correctChoice,
    @JsonKey(name: 'is_correct') required bool isCorrect,
  }) = _QuizReviewItem;

  factory QuizReviewItem.fromJson(Map<String, Object?> json) =>
      _$QuizReviewItemFromJson(json);
}

@freezed
class QuizGradingResult with _$QuizGradingResult {
  const factory QuizGradingResult({
    required int score,
    required int total,
    @Default(<UserAnswer>[]) List<UserAnswer> wrongQuestions,
    @Default(<QuizReviewItem>[]) List<QuizReviewItem> review,
    DateTime? completedAt,
  }) = _QuizGradingResult;

  factory QuizGradingResult.fromJson(Map<String, Object?> json) =>
      _$QuizGradingResultFromJson(json);
}

@freezed
class QuizAttempt with _$QuizAttempt {
  const factory QuizAttempt({
    required String id,
    @JsonKey(name: 'quizId') required String quizId,
    @JsonKey(name: 'quizTitle') required String quizTitle,
    required int score,
    required int total,
    @JsonKey(name: 'score10') required double score10,
    @Default(<QuizReviewItem>[]) List<QuizReviewItem> review,
    @JsonKey(name: 'duration_seconds') int? durationSeconds,
    DateTime? completedAt,
  }) = _QuizAttempt;

  factory QuizAttempt.fromJson(Map<String, Object?> json) =>
      _$QuizAttemptFromJson(json);
}
