// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_deck.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FlashcardDeckImpl _$$FlashcardDeckImplFromJson(Map<String, dynamic> json) =>
    _$FlashcardDeckImpl(
      id: json['id'] as String,
      uId: json['uId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
      cardCount: (json['cardCount'] as num?)?.toInt() ?? 0,
      lastStudiedAt: json['lastStudiedAt'] == null
          ? null
          : DateTime.parse(json['lastStudiedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$FlashcardDeckImplToJson(_$FlashcardDeckImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uId': instance.uId,
      'title': instance.title,
      'description': instance.description,
      'tags': instance.tags,
      'cardCount': instance.cardCount,
      'lastStudiedAt': instance.lastStudiedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };
