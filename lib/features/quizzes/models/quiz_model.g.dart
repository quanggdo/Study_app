// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuizImpl _$$QuizImplFromJson(Map<String, dynamic> json) => _$QuizImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String?,
      author: json['author'] as String?,
      timeLimit: (json['timeLimit'] as num?)?.toInt(),
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <QuizQuestion>[],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$QuizImplToJson(_$QuizImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'category': instance.category,
      'author': instance.author,
      'timeLimit': instance.timeLimit,
      'questions': instance.questions,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$QuizQuestionImpl _$$QuizQuestionImplFromJson(Map<String, dynamic> json) =>
    _$QuizQuestionImpl(
      qId: json['q_id'] as String,
      question: json['question'] as String,
      choices: (json['choices'] as List<dynamic>?)
              ?.map((e) => QuizChoice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <QuizChoice>[],
    );

Map<String, dynamic> _$$QuizQuestionImplToJson(_$QuizQuestionImpl instance) =>
    <String, dynamic>{
      'q_id': instance.qId,
      'question': instance.question,
      'choices': instance.choices,
    };

_$QuizChoiceImpl _$$QuizChoiceImplFromJson(Map<String, dynamic> json) =>
    _$QuizChoiceImpl(
      id: json['id'] as String,
      text: json['text'] as String,
    );

Map<String, dynamic> _$$QuizChoiceImplToJson(_$QuizChoiceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
    };
