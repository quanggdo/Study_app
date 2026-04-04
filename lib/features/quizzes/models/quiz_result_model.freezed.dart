// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quiz_result_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserAnswer _$UserAnswerFromJson(Map<String, dynamic> json) {
  return _UserAnswer.fromJson(json);
}

/// @nodoc
mixin _$UserAnswer {
  @JsonKey(name: 'q_id')
  String get qId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_choice')
  String get userChoice => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserAnswerCopyWith<UserAnswer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserAnswerCopyWith<$Res> {
  factory $UserAnswerCopyWith(
          UserAnswer value, $Res Function(UserAnswer) then) =
      _$UserAnswerCopyWithImpl<$Res, UserAnswer>;
  @useResult
  $Res call(
      {@JsonKey(name: 'q_id') String qId,
      @JsonKey(name: 'user_choice') String userChoice});
}

/// @nodoc
class _$UserAnswerCopyWithImpl<$Res, $Val extends UserAnswer>
    implements $UserAnswerCopyWith<$Res> {
  _$UserAnswerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? qId = null,
    Object? userChoice = null,
  }) {
    return _then(_value.copyWith(
      qId: null == qId
          ? _value.qId
          : qId // ignore: cast_nullable_to_non_nullable
              as String,
      userChoice: null == userChoice
          ? _value.userChoice
          : userChoice // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserAnswerImplCopyWith<$Res>
    implements $UserAnswerCopyWith<$Res> {
  factory _$$UserAnswerImplCopyWith(
          _$UserAnswerImpl value, $Res Function(_$UserAnswerImpl) then) =
      __$$UserAnswerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'q_id') String qId,
      @JsonKey(name: 'user_choice') String userChoice});
}

/// @nodoc
class __$$UserAnswerImplCopyWithImpl<$Res>
    extends _$UserAnswerCopyWithImpl<$Res, _$UserAnswerImpl>
    implements _$$UserAnswerImplCopyWith<$Res> {
  __$$UserAnswerImplCopyWithImpl(
      _$UserAnswerImpl _value, $Res Function(_$UserAnswerImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? qId = null,
    Object? userChoice = null,
  }) {
    return _then(_$UserAnswerImpl(
      qId: null == qId
          ? _value.qId
          : qId // ignore: cast_nullable_to_non_nullable
              as String,
      userChoice: null == userChoice
          ? _value.userChoice
          : userChoice // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserAnswerImpl implements _UserAnswer {
  const _$UserAnswerImpl(
      {@JsonKey(name: 'q_id') required this.qId,
      @JsonKey(name: 'user_choice') required this.userChoice});

  factory _$UserAnswerImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserAnswerImplFromJson(json);

  @override
  @JsonKey(name: 'q_id')
  final String qId;
  @override
  @JsonKey(name: 'user_choice')
  final String userChoice;

  @override
  String toString() {
    return 'UserAnswer(qId: $qId, userChoice: $userChoice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserAnswerImpl &&
            (identical(other.qId, qId) || other.qId == qId) &&
            (identical(other.userChoice, userChoice) ||
                other.userChoice == userChoice));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, qId, userChoice);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserAnswerImplCopyWith<_$UserAnswerImpl> get copyWith =>
      __$$UserAnswerImplCopyWithImpl<_$UserAnswerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserAnswerImplToJson(
      this,
    );
  }
}

abstract class _UserAnswer implements UserAnswer {
  const factory _UserAnswer(
          {@JsonKey(name: 'q_id') required final String qId,
          @JsonKey(name: 'user_choice') required final String userChoice}) =
      _$UserAnswerImpl;

  factory _UserAnswer.fromJson(Map<String, dynamic> json) =
      _$UserAnswerImpl.fromJson;

  @override
  @JsonKey(name: 'q_id')
  String get qId;
  @override
  @JsonKey(name: 'user_choice')
  String get userChoice;
  @override
  @JsonKey(ignore: true)
  _$$UserAnswerImplCopyWith<_$UserAnswerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QuizReviewItem _$QuizReviewItemFromJson(Map<String, dynamic> json) {
  return _QuizReviewItem.fromJson(json);
}

/// @nodoc
mixin _$QuizReviewItem {
  @JsonKey(name: 'q_id')
  String get qId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_choice')
  String get userChoice => throw _privateConstructorUsedError;
  @JsonKey(name: 'correct_choice')
  String get correctChoice => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_correct')
  bool get isCorrect => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuizReviewItemCopyWith<QuizReviewItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuizReviewItemCopyWith<$Res> {
  factory $QuizReviewItemCopyWith(
          QuizReviewItem value, $Res Function(QuizReviewItem) then) =
      _$QuizReviewItemCopyWithImpl<$Res, QuizReviewItem>;
  @useResult
  $Res call(
      {@JsonKey(name: 'q_id') String qId,
      @JsonKey(name: 'user_choice') String userChoice,
      @JsonKey(name: 'correct_choice') String correctChoice,
      @JsonKey(name: 'is_correct') bool isCorrect});
}

/// @nodoc
class _$QuizReviewItemCopyWithImpl<$Res, $Val extends QuizReviewItem>
    implements $QuizReviewItemCopyWith<$Res> {
  _$QuizReviewItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? qId = null,
    Object? userChoice = null,
    Object? correctChoice = null,
    Object? isCorrect = null,
  }) {
    return _then(_value.copyWith(
      qId: null == qId
          ? _value.qId
          : qId // ignore: cast_nullable_to_non_nullable
              as String,
      userChoice: null == userChoice
          ? _value.userChoice
          : userChoice // ignore: cast_nullable_to_non_nullable
              as String,
      correctChoice: null == correctChoice
          ? _value.correctChoice
          : correctChoice // ignore: cast_nullable_to_non_nullable
              as String,
      isCorrect: null == isCorrect
          ? _value.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuizReviewItemImplCopyWith<$Res>
    implements $QuizReviewItemCopyWith<$Res> {
  factory _$$QuizReviewItemImplCopyWith(_$QuizReviewItemImpl value,
          $Res Function(_$QuizReviewItemImpl) then) =
      __$$QuizReviewItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'q_id') String qId,
      @JsonKey(name: 'user_choice') String userChoice,
      @JsonKey(name: 'correct_choice') String correctChoice,
      @JsonKey(name: 'is_correct') bool isCorrect});
}

/// @nodoc
class __$$QuizReviewItemImplCopyWithImpl<$Res>
    extends _$QuizReviewItemCopyWithImpl<$Res, _$QuizReviewItemImpl>
    implements _$$QuizReviewItemImplCopyWith<$Res> {
  __$$QuizReviewItemImplCopyWithImpl(
      _$QuizReviewItemImpl _value, $Res Function(_$QuizReviewItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? qId = null,
    Object? userChoice = null,
    Object? correctChoice = null,
    Object? isCorrect = null,
  }) {
    return _then(_$QuizReviewItemImpl(
      qId: null == qId
          ? _value.qId
          : qId // ignore: cast_nullable_to_non_nullable
              as String,
      userChoice: null == userChoice
          ? _value.userChoice
          : userChoice // ignore: cast_nullable_to_non_nullable
              as String,
      correctChoice: null == correctChoice
          ? _value.correctChoice
          : correctChoice // ignore: cast_nullable_to_non_nullable
              as String,
      isCorrect: null == isCorrect
          ? _value.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuizReviewItemImpl implements _QuizReviewItem {
  const _$QuizReviewItemImpl(
      {@JsonKey(name: 'q_id') required this.qId,
      @JsonKey(name: 'user_choice') required this.userChoice,
      @JsonKey(name: 'correct_choice') required this.correctChoice,
      @JsonKey(name: 'is_correct') required this.isCorrect});

  factory _$QuizReviewItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuizReviewItemImplFromJson(json);

  @override
  @JsonKey(name: 'q_id')
  final String qId;
  @override
  @JsonKey(name: 'user_choice')
  final String userChoice;
  @override
  @JsonKey(name: 'correct_choice')
  final String correctChoice;
  @override
  @JsonKey(name: 'is_correct')
  final bool isCorrect;

  @override
  String toString() {
    return 'QuizReviewItem(qId: $qId, userChoice: $userChoice, correctChoice: $correctChoice, isCorrect: $isCorrect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuizReviewItemImpl &&
            (identical(other.qId, qId) || other.qId == qId) &&
            (identical(other.userChoice, userChoice) ||
                other.userChoice == userChoice) &&
            (identical(other.correctChoice, correctChoice) ||
                other.correctChoice == correctChoice) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, qId, userChoice, correctChoice, isCorrect);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuizReviewItemImplCopyWith<_$QuizReviewItemImpl> get copyWith =>
      __$$QuizReviewItemImplCopyWithImpl<_$QuizReviewItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuizReviewItemImplToJson(
      this,
    );
  }
}

abstract class _QuizReviewItem implements QuizReviewItem {
  const factory _QuizReviewItem(
          {@JsonKey(name: 'q_id') required final String qId,
          @JsonKey(name: 'user_choice') required final String userChoice,
          @JsonKey(name: 'correct_choice') required final String correctChoice,
          @JsonKey(name: 'is_correct') required final bool isCorrect}) =
      _$QuizReviewItemImpl;

  factory _QuizReviewItem.fromJson(Map<String, dynamic> json) =
      _$QuizReviewItemImpl.fromJson;

  @override
  @JsonKey(name: 'q_id')
  String get qId;
  @override
  @JsonKey(name: 'user_choice')
  String get userChoice;
  @override
  @JsonKey(name: 'correct_choice')
  String get correctChoice;
  @override
  @JsonKey(name: 'is_correct')
  bool get isCorrect;
  @override
  @JsonKey(ignore: true)
  _$$QuizReviewItemImplCopyWith<_$QuizReviewItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QuizGradingResult _$QuizGradingResultFromJson(Map<String, dynamic> json) {
  return _QuizGradingResult.fromJson(json);
}

/// @nodoc
mixin _$QuizGradingResult {
  int get score => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  List<UserAnswer> get wrongQuestions => throw _privateConstructorUsedError;
  List<QuizReviewItem> get review => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuizGradingResultCopyWith<QuizGradingResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuizGradingResultCopyWith<$Res> {
  factory $QuizGradingResultCopyWith(
          QuizGradingResult value, $Res Function(QuizGradingResult) then) =
      _$QuizGradingResultCopyWithImpl<$Res, QuizGradingResult>;
  @useResult
  $Res call(
      {int score,
      int total,
      List<UserAnswer> wrongQuestions,
      List<QuizReviewItem> review,
      DateTime? completedAt});
}

/// @nodoc
class _$QuizGradingResultCopyWithImpl<$Res, $Val extends QuizGradingResult>
    implements $QuizGradingResultCopyWith<$Res> {
  _$QuizGradingResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? score = null,
    Object? total = null,
    Object? wrongQuestions = null,
    Object? review = null,
    Object? completedAt = freezed,
  }) {
    return _then(_value.copyWith(
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      wrongQuestions: null == wrongQuestions
          ? _value.wrongQuestions
          : wrongQuestions // ignore: cast_nullable_to_non_nullable
              as List<UserAnswer>,
      review: null == review
          ? _value.review
          : review // ignore: cast_nullable_to_non_nullable
              as List<QuizReviewItem>,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuizGradingResultImplCopyWith<$Res>
    implements $QuizGradingResultCopyWith<$Res> {
  factory _$$QuizGradingResultImplCopyWith(_$QuizGradingResultImpl value,
          $Res Function(_$QuizGradingResultImpl) then) =
      __$$QuizGradingResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int score,
      int total,
      List<UserAnswer> wrongQuestions,
      List<QuizReviewItem> review,
      DateTime? completedAt});
}

/// @nodoc
class __$$QuizGradingResultImplCopyWithImpl<$Res>
    extends _$QuizGradingResultCopyWithImpl<$Res, _$QuizGradingResultImpl>
    implements _$$QuizGradingResultImplCopyWith<$Res> {
  __$$QuizGradingResultImplCopyWithImpl(_$QuizGradingResultImpl _value,
      $Res Function(_$QuizGradingResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? score = null,
    Object? total = null,
    Object? wrongQuestions = null,
    Object? review = null,
    Object? completedAt = freezed,
  }) {
    return _then(_$QuizGradingResultImpl(
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      wrongQuestions: null == wrongQuestions
          ? _value._wrongQuestions
          : wrongQuestions // ignore: cast_nullable_to_non_nullable
              as List<UserAnswer>,
      review: null == review
          ? _value._review
          : review // ignore: cast_nullable_to_non_nullable
              as List<QuizReviewItem>,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuizGradingResultImpl implements _QuizGradingResult {
  const _$QuizGradingResultImpl(
      {required this.score,
      required this.total,
      final List<UserAnswer> wrongQuestions = const <UserAnswer>[],
      final List<QuizReviewItem> review = const <QuizReviewItem>[],
      this.completedAt})
      : _wrongQuestions = wrongQuestions,
        _review = review;

  factory _$QuizGradingResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuizGradingResultImplFromJson(json);

  @override
  final int score;
  @override
  final int total;
  final List<UserAnswer> _wrongQuestions;
  @override
  @JsonKey()
  List<UserAnswer> get wrongQuestions {
    if (_wrongQuestions is EqualUnmodifiableListView) return _wrongQuestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_wrongQuestions);
  }

  final List<QuizReviewItem> _review;
  @override
  @JsonKey()
  List<QuizReviewItem> get review {
    if (_review is EqualUnmodifiableListView) return _review;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_review);
  }

  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'QuizGradingResult(score: $score, total: $total, wrongQuestions: $wrongQuestions, review: $review, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuizGradingResultImpl &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.total, total) || other.total == total) &&
            const DeepCollectionEquality()
                .equals(other._wrongQuestions, _wrongQuestions) &&
            const DeepCollectionEquality().equals(other._review, _review) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      score,
      total,
      const DeepCollectionEquality().hash(_wrongQuestions),
      const DeepCollectionEquality().hash(_review),
      completedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuizGradingResultImplCopyWith<_$QuizGradingResultImpl> get copyWith =>
      __$$QuizGradingResultImplCopyWithImpl<_$QuizGradingResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuizGradingResultImplToJson(
      this,
    );
  }
}

abstract class _QuizGradingResult implements QuizGradingResult {
  const factory _QuizGradingResult(
      {required final int score,
      required final int total,
      final List<UserAnswer> wrongQuestions,
      final List<QuizReviewItem> review,
      final DateTime? completedAt}) = _$QuizGradingResultImpl;

  factory _QuizGradingResult.fromJson(Map<String, dynamic> json) =
      _$QuizGradingResultImpl.fromJson;

  @override
  int get score;
  @override
  int get total;
  @override
  List<UserAnswer> get wrongQuestions;
  @override
  List<QuizReviewItem> get review;
  @override
  DateTime? get completedAt;
  @override
  @JsonKey(ignore: true)
  _$$QuizGradingResultImplCopyWith<_$QuizGradingResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QuizAttempt _$QuizAttemptFromJson(Map<String, dynamic> json) {
  return _QuizAttempt.fromJson(json);
}

/// @nodoc
mixin _$QuizAttempt {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'quizId')
  String get quizId => throw _privateConstructorUsedError;
  @JsonKey(name: 'quizTitle')
  String get quizTitle => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  @JsonKey(name: 'score10')
  double get score10 => throw _privateConstructorUsedError;
  List<QuizReviewItem> get review => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_seconds')
  int? get durationSeconds => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuizAttemptCopyWith<QuizAttempt> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuizAttemptCopyWith<$Res> {
  factory $QuizAttemptCopyWith(
          QuizAttempt value, $Res Function(QuizAttempt) then) =
      _$QuizAttemptCopyWithImpl<$Res, QuizAttempt>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'quizId') String quizId,
      @JsonKey(name: 'quizTitle') String quizTitle,
      int score,
      int total,
      @JsonKey(name: 'score10') double score10,
      List<QuizReviewItem> review,
      @JsonKey(name: 'duration_seconds') int? durationSeconds,
      DateTime? completedAt});
}

/// @nodoc
class _$QuizAttemptCopyWithImpl<$Res, $Val extends QuizAttempt>
    implements $QuizAttemptCopyWith<$Res> {
  _$QuizAttemptCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? quizId = null,
    Object? quizTitle = null,
    Object? score = null,
    Object? total = null,
    Object? score10 = null,
    Object? review = null,
    Object? durationSeconds = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      quizId: null == quizId
          ? _value.quizId
          : quizId // ignore: cast_nullable_to_non_nullable
              as String,
      quizTitle: null == quizTitle
          ? _value.quizTitle
          : quizTitle // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      score10: null == score10
          ? _value.score10
          : score10 // ignore: cast_nullable_to_non_nullable
              as double,
      review: null == review
          ? _value.review
          : review // ignore: cast_nullable_to_non_nullable
              as List<QuizReviewItem>,
      durationSeconds: freezed == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuizAttemptImplCopyWith<$Res>
    implements $QuizAttemptCopyWith<$Res> {
  factory _$$QuizAttemptImplCopyWith(
          _$QuizAttemptImpl value, $Res Function(_$QuizAttemptImpl) then) =
      __$$QuizAttemptImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'quizId') String quizId,
      @JsonKey(name: 'quizTitle') String quizTitle,
      int score,
      int total,
      @JsonKey(name: 'score10') double score10,
      List<QuizReviewItem> review,
      @JsonKey(name: 'duration_seconds') int? durationSeconds,
      DateTime? completedAt});
}

/// @nodoc
class __$$QuizAttemptImplCopyWithImpl<$Res>
    extends _$QuizAttemptCopyWithImpl<$Res, _$QuizAttemptImpl>
    implements _$$QuizAttemptImplCopyWith<$Res> {
  __$$QuizAttemptImplCopyWithImpl(
      _$QuizAttemptImpl _value, $Res Function(_$QuizAttemptImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? quizId = null,
    Object? quizTitle = null,
    Object? score = null,
    Object? total = null,
    Object? score10 = null,
    Object? review = null,
    Object? durationSeconds = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(_$QuizAttemptImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      quizId: null == quizId
          ? _value.quizId
          : quizId // ignore: cast_nullable_to_non_nullable
              as String,
      quizTitle: null == quizTitle
          ? _value.quizTitle
          : quizTitle // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      score10: null == score10
          ? _value.score10
          : score10 // ignore: cast_nullable_to_non_nullable
              as double,
      review: null == review
          ? _value._review
          : review // ignore: cast_nullable_to_non_nullable
              as List<QuizReviewItem>,
      durationSeconds: freezed == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuizAttemptImpl implements _QuizAttempt {
  const _$QuizAttemptImpl(
      {required this.id,
      @JsonKey(name: 'quizId') required this.quizId,
      @JsonKey(name: 'quizTitle') required this.quizTitle,
      required this.score,
      required this.total,
      @JsonKey(name: 'score10') required this.score10,
      final List<QuizReviewItem> review = const <QuizReviewItem>[],
      @JsonKey(name: 'duration_seconds') this.durationSeconds,
      this.completedAt})
      : _review = review;

  factory _$QuizAttemptImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuizAttemptImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'quizId')
  final String quizId;
  @override
  @JsonKey(name: 'quizTitle')
  final String quizTitle;
  @override
  final int score;
  @override
  final int total;
  @override
  @JsonKey(name: 'score10')
  final double score10;
  final List<QuizReviewItem> _review;
  @override
  @JsonKey()
  List<QuizReviewItem> get review {
    if (_review is EqualUnmodifiableListView) return _review;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_review);
  }

  @override
  @JsonKey(name: 'duration_seconds')
  final int? durationSeconds;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'QuizAttempt(id: $id, quizId: $quizId, quizTitle: $quizTitle, score: $score, total: $total, score10: $score10, review: $review, durationSeconds: $durationSeconds, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuizAttemptImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.quizId, quizId) || other.quizId == quizId) &&
            (identical(other.quizTitle, quizTitle) ||
                other.quizTitle == quizTitle) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.score10, score10) || other.score10 == score10) &&
            const DeepCollectionEquality().equals(other._review, _review) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      quizId,
      quizTitle,
      score,
      total,
      score10,
      const DeepCollectionEquality().hash(_review),
      durationSeconds,
      completedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuizAttemptImplCopyWith<_$QuizAttemptImpl> get copyWith =>
      __$$QuizAttemptImplCopyWithImpl<_$QuizAttemptImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuizAttemptImplToJson(
      this,
    );
  }
}

abstract class _QuizAttempt implements QuizAttempt {
  const factory _QuizAttempt(
      {required final String id,
      @JsonKey(name: 'quizId') required final String quizId,
      @JsonKey(name: 'quizTitle') required final String quizTitle,
      required final int score,
      required final int total,
      @JsonKey(name: 'score10') required final double score10,
      final List<QuizReviewItem> review,
      @JsonKey(name: 'duration_seconds') final int? durationSeconds,
      final DateTime? completedAt}) = _$QuizAttemptImpl;

  factory _QuizAttempt.fromJson(Map<String, dynamic> json) =
      _$QuizAttemptImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'quizId')
  String get quizId;
  @override
  @JsonKey(name: 'quizTitle')
  String get quizTitle;
  @override
  int get score;
  @override
  int get total;
  @override
  @JsonKey(name: 'score10')
  double get score10;
  @override
  List<QuizReviewItem> get review;
  @override
  @JsonKey(name: 'duration_seconds')
  int? get durationSeconds;
  @override
  DateTime? get completedAt;
  @override
  @JsonKey(ignore: true)
  _$$QuizAttemptImplCopyWith<_$QuizAttemptImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
