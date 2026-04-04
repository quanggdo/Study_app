// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserAnswerImpl _$$UserAnswerImplFromJson(Map<String, dynamic> json) =>
    _$UserAnswerImpl(
      qId: json['q_id'] as String,
      userChoice: json['user_choice'] as String,
    );

Map<String, dynamic> _$$UserAnswerImplToJson(_$UserAnswerImpl instance) =>
    <String, dynamic>{
      'q_id': instance.qId,
      'user_choice': instance.userChoice,
    };

_$QuizReviewItemImpl _$$QuizReviewItemImplFromJson(Map<String, dynamic> json) =>
    _$QuizReviewItemImpl(
      qId: json['q_id'] as String,
      userChoice: json['user_choice'] as String,
      correctChoice: json['correct_choice'] as String,
      isCorrect: json['is_correct'] as bool,
    );

Map<String, dynamic> _$$QuizReviewItemImplToJson(
        _$QuizReviewItemImpl instance) =>
    <String, dynamic>{
      'q_id': instance.qId,
      'user_choice': instance.userChoice,
      'correct_choice': instance.correctChoice,
      'is_correct': instance.isCorrect,
    };

_$QuizGradingResultImpl _$$QuizGradingResultImplFromJson(
        Map<String, dynamic> json) =>
    _$QuizGradingResultImpl(
      score: (json['score'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      wrongQuestions: (json['wrongQuestions'] as List<dynamic>?)
              ?.map((e) => UserAnswer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <UserAnswer>[],
      review: (json['review'] as List<dynamic>?)
              ?.map((e) => QuizReviewItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <QuizReviewItem>[],
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$QuizGradingResultImplToJson(
        _$QuizGradingResultImpl instance) =>
    <String, dynamic>{
      'score': instance.score,
      'total': instance.total,
      'wrongQuestions': instance.wrongQuestions,
      'review': instance.review,
      'completedAt': instance.completedAt?.toIso8601String(),
    };

_$QuizAttemptImpl _$$QuizAttemptImplFromJson(Map<String, dynamic> json) =>
    _$QuizAttemptImpl(
      id: json['id'] as String,
      quizId: json['quizId'] as String,
      quizTitle: json['quizTitle'] as String,
      score: (json['score'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      score10: (json['score10'] as num).toDouble(),
      review: (json['review'] as List<dynamic>?)
              ?.map((e) => QuizReviewItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <QuizReviewItem>[],
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$QuizAttemptImplToJson(_$QuizAttemptImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'quizId': instance.quizId,
      'quizTitle': instance.quizTitle,
      'score': instance.score,
      'total': instance.total,
      'score10': instance.score10,
      'review': instance.review,
      'duration_seconds': instance.durationSeconds,
      'completedAt': instance.completedAt?.toIso8601String(),
    };
