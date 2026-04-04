import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz_model.freezed.dart';
part 'quiz_model.g.dart';

@freezed
class Quiz with _$Quiz {
  const factory Quiz({
    required String id,
    required String title,
    String? category,
    String? author,
    int? timeLimit,
    @Default(<QuizQuestion>[]) List<QuizQuestion> questions,
    DateTime? createdAt,
  }) = _Quiz;

  factory Quiz.fromJson(Map<String, Object?> json) => _$QuizFromJson(json);
}

@freezed
class QuizQuestion with _$QuizQuestion {
  const factory QuizQuestion({
    @JsonKey(name: 'q_id') required String qId,
    required String question,
    @Default(<QuizChoice>[]) List<QuizChoice> choices,
  }) = _QuizQuestion;

  factory QuizQuestion.fromJson(Map<String, Object?> json) =>
      _$QuizQuestionFromJson(json);
}

@freezed
class QuizChoice with _$QuizChoice {
  const factory QuizChoice({
    /// ID của lựa chọn (A/B/C/D hoặc 0/1/2/3)
    required String id,
    required String text,
  }) = _QuizChoice;

  factory QuizChoice.fromJson(Map<String, Object?> json) =>
      _$QuizChoiceFromJson(json);
}
