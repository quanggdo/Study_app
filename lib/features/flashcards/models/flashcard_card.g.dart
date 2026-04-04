// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FlashcardCardImpl _$$FlashcardCardImplFromJson(Map<String, dynamic> json) =>
    _$FlashcardCardImpl(
      id: json['id'] as String,
      deckId: json['deckId'] as String,
      uId: json['uId'] as String,
      front: json['front'] as String,
      back: json['back'] as String,
      hint: json['hint'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$FlashcardCardImplToJson(_$FlashcardCardImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deckId': instance.deckId,
      'uId': instance.uId,
      'front': instance.front,
      'back': instance.back,
      'hint': instance.hint,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };
