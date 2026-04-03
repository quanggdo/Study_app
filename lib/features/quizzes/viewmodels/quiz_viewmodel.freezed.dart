// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quiz_viewmodel.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$QuizSessionState {
  bool get loading => throw _privateConstructorUsedError;
  Quiz? get quiz => throw _privateConstructorUsedError;
  int get index => throw _privateConstructorUsedError;
  Map<String, String> get answersByQId => throw _privateConstructorUsedError;
  bool get submitting => throw _privateConstructorUsedError;
  QuizGradingResult? get result => throw _privateConstructorUsedError;
  Object? get error => throw _privateConstructorUsedError;

  /// Countdown (null = không giới hạn thời gian)
  int? get remainingSeconds => throw _privateConstructorUsedError;
  bool get timeUp => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $QuizSessionStateCopyWith<QuizSessionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuizSessionStateCopyWith<$Res> {
  factory $QuizSessionStateCopyWith(
          QuizSessionState value, $Res Function(QuizSessionState) then) =
      _$QuizSessionStateCopyWithImpl<$Res, QuizSessionState>;
  @useResult
  $Res call(
      {bool loading,
      Quiz? quiz,
      int index,
      Map<String, String> answersByQId,
      bool submitting,
      QuizGradingResult? result,
      Object? error,
      int? remainingSeconds,
      bool timeUp});

  $QuizCopyWith<$Res>? get quiz;
  $QuizGradingResultCopyWith<$Res>? get result;
}

/// @nodoc
class _$QuizSessionStateCopyWithImpl<$Res, $Val extends QuizSessionState>
    implements $QuizSessionStateCopyWith<$Res> {
  _$QuizSessionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loading = null,
    Object? quiz = freezed,
    Object? index = null,
    Object? answersByQId = null,
    Object? submitting = null,
    Object? result = freezed,
    Object? error = freezed,
    Object? remainingSeconds = freezed,
    Object? timeUp = null,
  }) {
    return _then(_value.copyWith(
      loading: null == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
              as bool,
      quiz: freezed == quiz
          ? _value.quiz
          : quiz // ignore: cast_nullable_to_non_nullable
              as Quiz?,
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      answersByQId: null == answersByQId
          ? _value.answersByQId
          : answersByQId // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      submitting: null == submitting
          ? _value.submitting
          : submitting // ignore: cast_nullable_to_non_nullable
              as bool,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as QuizGradingResult?,
      error: freezed == error ? _value.error : error,
      remainingSeconds: freezed == remainingSeconds
          ? _value.remainingSeconds
          : remainingSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      timeUp: null == timeUp
          ? _value.timeUp
          : timeUp // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $QuizCopyWith<$Res>? get quiz {
    if (_value.quiz == null) {
      return null;
    }

    return $QuizCopyWith<$Res>(_value.quiz!, (value) {
      return _then(_value.copyWith(quiz: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $QuizGradingResultCopyWith<$Res>? get result {
    if (_value.result == null) {
      return null;
    }

    return $QuizGradingResultCopyWith<$Res>(_value.result!, (value) {
      return _then(_value.copyWith(result: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$QuizSessionStateImplCopyWith<$Res>
    implements $QuizSessionStateCopyWith<$Res> {
  factory _$$QuizSessionStateImplCopyWith(_$QuizSessionStateImpl value,
          $Res Function(_$QuizSessionStateImpl) then) =
      __$$QuizSessionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool loading,
      Quiz? quiz,
      int index,
      Map<String, String> answersByQId,
      bool submitting,
      QuizGradingResult? result,
      Object? error,
      int? remainingSeconds,
      bool timeUp});

  @override
  $QuizCopyWith<$Res>? get quiz;
  @override
  $QuizGradingResultCopyWith<$Res>? get result;
}

/// @nodoc
class __$$QuizSessionStateImplCopyWithImpl<$Res>
    extends _$QuizSessionStateCopyWithImpl<$Res, _$QuizSessionStateImpl>
    implements _$$QuizSessionStateImplCopyWith<$Res> {
  __$$QuizSessionStateImplCopyWithImpl(_$QuizSessionStateImpl _value,
      $Res Function(_$QuizSessionStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loading = null,
    Object? quiz = freezed,
    Object? index = null,
    Object? answersByQId = null,
    Object? submitting = null,
    Object? result = freezed,
    Object? error = freezed,
    Object? remainingSeconds = freezed,
    Object? timeUp = null,
  }) {
    return _then(_$QuizSessionStateImpl(
      loading: null == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
              as bool,
      quiz: freezed == quiz
          ? _value.quiz
          : quiz // ignore: cast_nullable_to_non_nullable
              as Quiz?,
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      answersByQId: null == answersByQId
          ? _value._answersByQId
          : answersByQId // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      submitting: null == submitting
          ? _value.submitting
          : submitting // ignore: cast_nullable_to_non_nullable
              as bool,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as QuizGradingResult?,
      error: freezed == error ? _value.error : error,
      remainingSeconds: freezed == remainingSeconds
          ? _value.remainingSeconds
          : remainingSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      timeUp: null == timeUp
          ? _value.timeUp
          : timeUp // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$QuizSessionStateImpl implements _QuizSessionState {
  const _$QuizSessionStateImpl(
      {this.loading = true,
      this.quiz,
      this.index = 0,
      final Map<String, String> answersByQId = const {},
      this.submitting = false,
      this.result,
      this.error,
      this.remainingSeconds,
      this.timeUp = false})
      : _answersByQId = answersByQId;

  @override
  @JsonKey()
  final bool loading;
  @override
  final Quiz? quiz;
  @override
  @JsonKey()
  final int index;
  final Map<String, String> _answersByQId;
  @override
  @JsonKey()
  Map<String, String> get answersByQId {
    if (_answersByQId is EqualUnmodifiableMapView) return _answersByQId;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_answersByQId);
  }

  @override
  @JsonKey()
  final bool submitting;
  @override
  final QuizGradingResult? result;
  @override
  final Object? error;

  /// Countdown (null = không giới hạn thời gian)
  @override
  final int? remainingSeconds;
  @override
  @JsonKey()
  final bool timeUp;

  @override
  String toString() {
    return 'QuizSessionState(loading: $loading, quiz: $quiz, index: $index, answersByQId: $answersByQId, submitting: $submitting, result: $result, error: $error, remainingSeconds: $remainingSeconds, timeUp: $timeUp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuizSessionStateImpl &&
            (identical(other.loading, loading) || other.loading == loading) &&
            (identical(other.quiz, quiz) || other.quiz == quiz) &&
            (identical(other.index, index) || other.index == index) &&
            const DeepCollectionEquality()
                .equals(other._answersByQId, _answersByQId) &&
            (identical(other.submitting, submitting) ||
                other.submitting == submitting) &&
            (identical(other.result, result) || other.result == result) &&
            const DeepCollectionEquality().equals(other.error, error) &&
            (identical(other.remainingSeconds, remainingSeconds) ||
                other.remainingSeconds == remainingSeconds) &&
            (identical(other.timeUp, timeUp) || other.timeUp == timeUp));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      loading,
      quiz,
      index,
      const DeepCollectionEquality().hash(_answersByQId),
      submitting,
      result,
      const DeepCollectionEquality().hash(error),
      remainingSeconds,
      timeUp);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuizSessionStateImplCopyWith<_$QuizSessionStateImpl> get copyWith =>
      __$$QuizSessionStateImplCopyWithImpl<_$QuizSessionStateImpl>(
          this, _$identity);
}

abstract class _QuizSessionState implements QuizSessionState {
  const factory _QuizSessionState(
      {final bool loading,
      final Quiz? quiz,
      final int index,
      final Map<String, String> answersByQId,
      final bool submitting,
      final QuizGradingResult? result,
      final Object? error,
      final int? remainingSeconds,
      final bool timeUp}) = _$QuizSessionStateImpl;

  @override
  bool get loading;
  @override
  Quiz? get quiz;
  @override
  int get index;
  @override
  Map<String, String> get answersByQId;
  @override
  bool get submitting;
  @override
  QuizGradingResult? get result;
  @override
  Object? get error;
  @override

  /// Countdown (null = không giới hạn thời gian)
  int? get remainingSeconds;
  @override
  bool get timeUp;
  @override
  @JsonKey(ignore: true)
  _$$QuizSessionStateImplCopyWith<_$QuizSessionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
