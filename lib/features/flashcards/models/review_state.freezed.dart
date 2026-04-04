// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReviewState _$ReviewStateFromJson(Map<String, dynamic> json) {
  return _ReviewState.fromJson(json);
}

/// @nodoc
mixin _$ReviewState {
  String get cardId => throw _privateConstructorUsedError;
  String get deckId => throw _privateConstructorUsedError;
  String get uId => throw _privateConstructorUsedError;
  DateTime get dueAt => throw _privateConstructorUsedError;
  int get reps => throw _privateConstructorUsedError;
  int get lapses => throw _privateConstructorUsedError;
  int get intervalDays => throw _privateConstructorUsedError;
  int get intervalMinutes => throw _privateConstructorUsedError;
  ReviewStateType get stateType => throw _privateConstructorUsedError;
  double get easeFactor => throw _privateConstructorUsedError;
  DateTime? get lastReviewedAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReviewStateCopyWith<ReviewState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewStateCopyWith<$Res> {
  factory $ReviewStateCopyWith(
          ReviewState value, $Res Function(ReviewState) then) =
      _$ReviewStateCopyWithImpl<$Res, ReviewState>;
  @useResult
  $Res call(
      {String cardId,
      String deckId,
      String uId,
      DateTime dueAt,
      int reps,
      int lapses,
      int intervalDays,
      int intervalMinutes,
      ReviewStateType stateType,
      double easeFactor,
      DateTime? lastReviewedAt,
      DateTime updatedAt,
      bool isDeleted});
}

/// @nodoc
class _$ReviewStateCopyWithImpl<$Res, $Val extends ReviewState>
    implements $ReviewStateCopyWith<$Res> {
  _$ReviewStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cardId = null,
    Object? deckId = null,
    Object? uId = null,
    Object? dueAt = null,
    Object? reps = null,
    Object? lapses = null,
    Object? intervalDays = null,
    Object? intervalMinutes = null,
    Object? stateType = null,
    Object? easeFactor = null,
    Object? lastReviewedAt = freezed,
    Object? updatedAt = null,
    Object? isDeleted = null,
  }) {
    return _then(_value.copyWith(
      cardId: null == cardId
          ? _value.cardId
          : cardId // ignore: cast_nullable_to_non_nullable
              as String,
      deckId: null == deckId
          ? _value.deckId
          : deckId // ignore: cast_nullable_to_non_nullable
              as String,
      uId: null == uId
          ? _value.uId
          : uId // ignore: cast_nullable_to_non_nullable
              as String,
      dueAt: null == dueAt
          ? _value.dueAt
          : dueAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      lapses: null == lapses
          ? _value.lapses
          : lapses // ignore: cast_nullable_to_non_nullable
              as int,
      intervalDays: null == intervalDays
          ? _value.intervalDays
          : intervalDays // ignore: cast_nullable_to_non_nullable
              as int,
      intervalMinutes: null == intervalMinutes
          ? _value.intervalMinutes
          : intervalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      stateType: null == stateType
          ? _value.stateType
          : stateType // ignore: cast_nullable_to_non_nullable
              as ReviewStateType,
      easeFactor: null == easeFactor
          ? _value.easeFactor
          : easeFactor // ignore: cast_nullable_to_non_nullable
              as double,
      lastReviewedAt: freezed == lastReviewedAt
          ? _value.lastReviewedAt
          : lastReviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReviewStateImplCopyWith<$Res>
    implements $ReviewStateCopyWith<$Res> {
  factory _$$ReviewStateImplCopyWith(
          _$ReviewStateImpl value, $Res Function(_$ReviewStateImpl) then) =
      __$$ReviewStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String cardId,
      String deckId,
      String uId,
      DateTime dueAt,
      int reps,
      int lapses,
      int intervalDays,
      int intervalMinutes,
      ReviewStateType stateType,
      double easeFactor,
      DateTime? lastReviewedAt,
      DateTime updatedAt,
      bool isDeleted});
}

/// @nodoc
class __$$ReviewStateImplCopyWithImpl<$Res>
    extends _$ReviewStateCopyWithImpl<$Res, _$ReviewStateImpl>
    implements _$$ReviewStateImplCopyWith<$Res> {
  __$$ReviewStateImplCopyWithImpl(
      _$ReviewStateImpl _value, $Res Function(_$ReviewStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cardId = null,
    Object? deckId = null,
    Object? uId = null,
    Object? dueAt = null,
    Object? reps = null,
    Object? lapses = null,
    Object? intervalDays = null,
    Object? intervalMinutes = null,
    Object? stateType = null,
    Object? easeFactor = null,
    Object? lastReviewedAt = freezed,
    Object? updatedAt = null,
    Object? isDeleted = null,
  }) {
    return _then(_$ReviewStateImpl(
      cardId: null == cardId
          ? _value.cardId
          : cardId // ignore: cast_nullable_to_non_nullable
              as String,
      deckId: null == deckId
          ? _value.deckId
          : deckId // ignore: cast_nullable_to_non_nullable
              as String,
      uId: null == uId
          ? _value.uId
          : uId // ignore: cast_nullable_to_non_nullable
              as String,
      dueAt: null == dueAt
          ? _value.dueAt
          : dueAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      lapses: null == lapses
          ? _value.lapses
          : lapses // ignore: cast_nullable_to_non_nullable
              as int,
      intervalDays: null == intervalDays
          ? _value.intervalDays
          : intervalDays // ignore: cast_nullable_to_non_nullable
              as int,
      intervalMinutes: null == intervalMinutes
          ? _value.intervalMinutes
          : intervalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      stateType: null == stateType
          ? _value.stateType
          : stateType // ignore: cast_nullable_to_non_nullable
              as ReviewStateType,
      easeFactor: null == easeFactor
          ? _value.easeFactor
          : easeFactor // ignore: cast_nullable_to_non_nullable
              as double,
      lastReviewedAt: freezed == lastReviewedAt
          ? _value.lastReviewedAt
          : lastReviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewStateImpl implements _ReviewState {
  const _$ReviewStateImpl(
      {required this.cardId,
      required this.deckId,
      required this.uId,
      required this.dueAt,
      this.reps = 0,
      this.lapses = 0,
      this.intervalDays = 0,
      this.intervalMinutes = 0,
      this.stateType = ReviewStateType.learning,
      this.easeFactor = 2.5,
      this.lastReviewedAt,
      required this.updatedAt,
      this.isDeleted = false});

  factory _$ReviewStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewStateImplFromJson(json);

  @override
  final String cardId;
  @override
  final String deckId;
  @override
  final String uId;
  @override
  final DateTime dueAt;
  @override
  @JsonKey()
  final int reps;
  @override
  @JsonKey()
  final int lapses;
  @override
  @JsonKey()
  final int intervalDays;
  @override
  @JsonKey()
  final int intervalMinutes;
  @override
  @JsonKey()
  final ReviewStateType stateType;
  @override
  @JsonKey()
  final double easeFactor;
  @override
  final DateTime? lastReviewedAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final bool isDeleted;

  @override
  String toString() {
    return 'ReviewState(cardId: $cardId, deckId: $deckId, uId: $uId, dueAt: $dueAt, reps: $reps, lapses: $lapses, intervalDays: $intervalDays, intervalMinutes: $intervalMinutes, stateType: $stateType, easeFactor: $easeFactor, lastReviewedAt: $lastReviewedAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewStateImpl &&
            (identical(other.cardId, cardId) || other.cardId == cardId) &&
            (identical(other.deckId, deckId) || other.deckId == deckId) &&
            (identical(other.uId, uId) || other.uId == uId) &&
            (identical(other.dueAt, dueAt) || other.dueAt == dueAt) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.lapses, lapses) || other.lapses == lapses) &&
            (identical(other.intervalDays, intervalDays) ||
                other.intervalDays == intervalDays) &&
            (identical(other.intervalMinutes, intervalMinutes) ||
                other.intervalMinutes == intervalMinutes) &&
            (identical(other.stateType, stateType) ||
                other.stateType == stateType) &&
            (identical(other.easeFactor, easeFactor) ||
                other.easeFactor == easeFactor) &&
            (identical(other.lastReviewedAt, lastReviewedAt) ||
                other.lastReviewedAt == lastReviewedAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      cardId,
      deckId,
      uId,
      dueAt,
      reps,
      lapses,
      intervalDays,
      intervalMinutes,
      stateType,
      easeFactor,
      lastReviewedAt,
      updatedAt,
      isDeleted);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewStateImplCopyWith<_$ReviewStateImpl> get copyWith =>
      __$$ReviewStateImplCopyWithImpl<_$ReviewStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewStateImplToJson(
      this,
    );
  }
}

abstract class _ReviewState implements ReviewState {
  const factory _ReviewState(
      {required final String cardId,
      required final String deckId,
      required final String uId,
      required final DateTime dueAt,
      final int reps,
      final int lapses,
      final int intervalDays,
      final int intervalMinutes,
      final ReviewStateType stateType,
      final double easeFactor,
      final DateTime? lastReviewedAt,
      required final DateTime updatedAt,
      final bool isDeleted}) = _$ReviewStateImpl;

  factory _ReviewState.fromJson(Map<String, dynamic> json) =
      _$ReviewStateImpl.fromJson;

  @override
  String get cardId;
  @override
  String get deckId;
  @override
  String get uId;
  @override
  DateTime get dueAt;
  @override
  int get reps;
  @override
  int get lapses;
  @override
  int get intervalDays;
  @override
  int get intervalMinutes;
  @override
  ReviewStateType get stateType;
  @override
  double get easeFactor;
  @override
  DateTime? get lastReviewedAt;
  @override
  DateTime get updatedAt;
  @override
  bool get isDeleted;
  @override
  @JsonKey(ignore: true)
  _$$ReviewStateImplCopyWith<_$ReviewStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
