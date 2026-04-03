// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReviewStateImpl _$$ReviewStateImplFromJson(Map<String, dynamic> json) =>
    _$ReviewStateImpl(
      cardId: json['cardId'] as String,
      deckId: json['deckId'] as String,
      uId: json['uId'] as String,
      dueAt: DateTime.parse(json['dueAt'] as String),
      reps: (json['reps'] as num?)?.toInt() ?? 0,
      lapses: (json['lapses'] as num?)?.toInt() ?? 0,
      intervalDays: (json['intervalDays'] as num?)?.toInt() ?? 0,
      intervalMinutes: (json['intervalMinutes'] as num?)?.toInt() ?? 0,
      stateType:
          $enumDecodeNullable(_$ReviewStateTypeEnumMap, json['stateType']) ??
              ReviewStateType.learning,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      lastReviewedAt: json['lastReviewedAt'] == null
          ? null
          : DateTime.parse(json['lastReviewedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$ReviewStateImplToJson(_$ReviewStateImpl instance) =>
    <String, dynamic>{
      'cardId': instance.cardId,
      'deckId': instance.deckId,
      'uId': instance.uId,
      'dueAt': instance.dueAt.toIso8601String(),
      'reps': instance.reps,
      'lapses': instance.lapses,
      'intervalDays': instance.intervalDays,
      'intervalMinutes': instance.intervalMinutes,
      'stateType': _$ReviewStateTypeEnumMap[instance.stateType]!,
      'easeFactor': instance.easeFactor,
      'lastReviewedAt': instance.lastReviewedAt?.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };

const _$ReviewStateTypeEnumMap = {
  ReviewStateType.learning: 'learning',
  ReviewStateType.review: 'review',
};
