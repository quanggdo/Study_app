// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quiz_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Quiz _$QuizFromJson(Map<String, dynamic> json) {
  return _Quiz.fromJson(json);
}

/// @nodoc
mixin _$Quiz {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get author => throw _privateConstructorUsedError;
  int? get timeLimit => throw _privateConstructorUsedError;
  List<QuizQuestion> get questions => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuizCopyWith<Quiz> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuizCopyWith<$Res> {
  factory $QuizCopyWith(Quiz value, $Res Function(Quiz) then) =
      _$QuizCopyWithImpl<$Res, Quiz>;
  @useResult
  $Res call(
      {String id,
      String title,
      String? category,
      String? author,
      int? timeLimit,
      List<QuizQuestion> questions,
      DateTime? createdAt});
}

/// @nodoc
class _$QuizCopyWithImpl<$Res, $Val extends Quiz>
    implements $QuizCopyWith<$Res> {
  _$QuizCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? category = freezed,
    Object? author = freezed,
    Object? timeLimit = freezed,
    Object? questions = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      author: freezed == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String?,
      timeLimit: freezed == timeLimit
          ? _value.timeLimit
          : timeLimit // ignore: cast_nullable_to_non_nullable
              as int?,
      questions: null == questions
          ? _value.questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<QuizQuestion>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuizImplCopyWith<$Res> implements $QuizCopyWith<$Res> {
  factory _$$QuizImplCopyWith(
          _$QuizImpl value, $Res Function(_$QuizImpl) then) =
      __$$QuizImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String? category,
      String? author,
      int? timeLimit,
      List<QuizQuestion> questions,
      DateTime? createdAt});
}

/// @nodoc
class __$$QuizImplCopyWithImpl<$Res>
    extends _$QuizCopyWithImpl<$Res, _$QuizImpl>
    implements _$$QuizImplCopyWith<$Res> {
  __$$QuizImplCopyWithImpl(_$QuizImpl _value, $Res Function(_$QuizImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? category = freezed,
    Object? author = freezed,
    Object? timeLimit = freezed,
    Object? questions = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$QuizImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      author: freezed == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String?,
      timeLimit: freezed == timeLimit
          ? _value.timeLimit
          : timeLimit // ignore: cast_nullable_to_non_nullable
              as int?,
      questions: null == questions
          ? _value._questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<QuizQuestion>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuizImpl implements _Quiz {
  const _$QuizImpl(
      {required this.id,
      required this.title,
      this.category,
      this.author,
      this.timeLimit,
      final List<QuizQuestion> questions = const <QuizQuestion>[],
      this.createdAt})
      : _questions = questions;

  factory _$QuizImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuizImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? category;
  @override
  final String? author;
  @override
  final int? timeLimit;
  final List<QuizQuestion> _questions;
  @override
  @JsonKey()
  List<QuizQuestion> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Quiz(id: $id, title: $title, category: $category, author: $author, timeLimit: $timeLimit, questions: $questions, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuizImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.timeLimit, timeLimit) ||
                other.timeLimit == timeLimit) &&
            const DeepCollectionEquality()
                .equals(other._questions, _questions) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, category, author,
      timeLimit, const DeepCollectionEquality().hash(_questions), createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuizImplCopyWith<_$QuizImpl> get copyWith =>
      __$$QuizImplCopyWithImpl<_$QuizImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuizImplToJson(
      this,
    );
  }
}

abstract class _Quiz implements Quiz {
  const factory _Quiz(
      {required final String id,
      required final String title,
      final String? category,
      final String? author,
      final int? timeLimit,
      final List<QuizQuestion> questions,
      final DateTime? createdAt}) = _$QuizImpl;

  factory _Quiz.fromJson(Map<String, dynamic> json) = _$QuizImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get category;
  @override
  String? get author;
  @override
  int? get timeLimit;
  @override
  List<QuizQuestion> get questions;
  @override
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$QuizImplCopyWith<_$QuizImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QuizQuestion _$QuizQuestionFromJson(Map<String, dynamic> json) {
  return _QuizQuestion.fromJson(json);
}

/// @nodoc
mixin _$QuizQuestion {
  @JsonKey(name: 'q_id')
  String get qId => throw _privateConstructorUsedError;
  String get question => throw _privateConstructorUsedError;
  List<QuizChoice> get choices => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuizQuestionCopyWith<QuizQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuizQuestionCopyWith<$Res> {
  factory $QuizQuestionCopyWith(
          QuizQuestion value, $Res Function(QuizQuestion) then) =
      _$QuizQuestionCopyWithImpl<$Res, QuizQuestion>;
  @useResult
  $Res call(
      {@JsonKey(name: 'q_id') String qId,
      String question,
      List<QuizChoice> choices});
}

/// @nodoc
class _$QuizQuestionCopyWithImpl<$Res, $Val extends QuizQuestion>
    implements $QuizQuestionCopyWith<$Res> {
  _$QuizQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? qId = null,
    Object? question = null,
    Object? choices = null,
  }) {
    return _then(_value.copyWith(
      qId: null == qId
          ? _value.qId
          : qId // ignore: cast_nullable_to_non_nullable
              as String,
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      choices: null == choices
          ? _value.choices
          : choices // ignore: cast_nullable_to_non_nullable
              as List<QuizChoice>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuizQuestionImplCopyWith<$Res>
    implements $QuizQuestionCopyWith<$Res> {
  factory _$$QuizQuestionImplCopyWith(
          _$QuizQuestionImpl value, $Res Function(_$QuizQuestionImpl) then) =
      __$$QuizQuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'q_id') String qId,
      String question,
      List<QuizChoice> choices});
}

/// @nodoc
class __$$QuizQuestionImplCopyWithImpl<$Res>
    extends _$QuizQuestionCopyWithImpl<$Res, _$QuizQuestionImpl>
    implements _$$QuizQuestionImplCopyWith<$Res> {
  __$$QuizQuestionImplCopyWithImpl(
      _$QuizQuestionImpl _value, $Res Function(_$QuizQuestionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? qId = null,
    Object? question = null,
    Object? choices = null,
  }) {
    return _then(_$QuizQuestionImpl(
      qId: null == qId
          ? _value.qId
          : qId // ignore: cast_nullable_to_non_nullable
              as String,
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      choices: null == choices
          ? _value._choices
          : choices // ignore: cast_nullable_to_non_nullable
              as List<QuizChoice>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuizQuestionImpl implements _QuizQuestion {
  const _$QuizQuestionImpl(
      {@JsonKey(name: 'q_id') required this.qId,
      required this.question,
      final List<QuizChoice> choices = const <QuizChoice>[]})
      : _choices = choices;

  factory _$QuizQuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuizQuestionImplFromJson(json);

  @override
  @JsonKey(name: 'q_id')
  final String qId;
  @override
  final String question;
  final List<QuizChoice> _choices;
  @override
  @JsonKey()
  List<QuizChoice> get choices {
    if (_choices is EqualUnmodifiableListView) return _choices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_choices);
  }

  @override
  String toString() {
    return 'QuizQuestion(qId: $qId, question: $question, choices: $choices)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuizQuestionImpl &&
            (identical(other.qId, qId) || other.qId == qId) &&
            (identical(other.question, question) ||
                other.question == question) &&
            const DeepCollectionEquality().equals(other._choices, _choices));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, qId, question,
      const DeepCollectionEquality().hash(_choices));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuizQuestionImplCopyWith<_$QuizQuestionImpl> get copyWith =>
      __$$QuizQuestionImplCopyWithImpl<_$QuizQuestionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuizQuestionImplToJson(
      this,
    );
  }
}

abstract class _QuizQuestion implements QuizQuestion {
  const factory _QuizQuestion(
      {@JsonKey(name: 'q_id') required final String qId,
      required final String question,
      final List<QuizChoice> choices}) = _$QuizQuestionImpl;

  factory _QuizQuestion.fromJson(Map<String, dynamic> json) =
      _$QuizQuestionImpl.fromJson;

  @override
  @JsonKey(name: 'q_id')
  String get qId;
  @override
  String get question;
  @override
  List<QuizChoice> get choices;
  @override
  @JsonKey(ignore: true)
  _$$QuizQuestionImplCopyWith<_$QuizQuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QuizChoice _$QuizChoiceFromJson(Map<String, dynamic> json) {
  return _QuizChoice.fromJson(json);
}

/// @nodoc
mixin _$QuizChoice {
  /// ID của lựa chọn (A/B/C/D hoặc 0/1/2/3)
  String get id => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuizChoiceCopyWith<QuizChoice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuizChoiceCopyWith<$Res> {
  factory $QuizChoiceCopyWith(
          QuizChoice value, $Res Function(QuizChoice) then) =
      _$QuizChoiceCopyWithImpl<$Res, QuizChoice>;
  @useResult
  $Res call({String id, String text});
}

/// @nodoc
class _$QuizChoiceCopyWithImpl<$Res, $Val extends QuizChoice>
    implements $QuizChoiceCopyWith<$Res> {
  _$QuizChoiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuizChoiceImplCopyWith<$Res>
    implements $QuizChoiceCopyWith<$Res> {
  factory _$$QuizChoiceImplCopyWith(
          _$QuizChoiceImpl value, $Res Function(_$QuizChoiceImpl) then) =
      __$$QuizChoiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String text});
}

/// @nodoc
class __$$QuizChoiceImplCopyWithImpl<$Res>
    extends _$QuizChoiceCopyWithImpl<$Res, _$QuizChoiceImpl>
    implements _$$QuizChoiceImplCopyWith<$Res> {
  __$$QuizChoiceImplCopyWithImpl(
      _$QuizChoiceImpl _value, $Res Function(_$QuizChoiceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
  }) {
    return _then(_$QuizChoiceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuizChoiceImpl implements _QuizChoice {
  const _$QuizChoiceImpl({required this.id, required this.text});

  factory _$QuizChoiceImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuizChoiceImplFromJson(json);

  /// ID của lựa chọn (A/B/C/D hoặc 0/1/2/3)
  @override
  final String id;
  @override
  final String text;

  @override
  String toString() {
    return 'QuizChoice(id: $id, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuizChoiceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, text);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuizChoiceImplCopyWith<_$QuizChoiceImpl> get copyWith =>
      __$$QuizChoiceImplCopyWithImpl<_$QuizChoiceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuizChoiceImplToJson(
      this,
    );
  }
}

abstract class _QuizChoice implements QuizChoice {
  const factory _QuizChoice(
      {required final String id,
      required final String text}) = _$QuizChoiceImpl;

  factory _QuizChoice.fromJson(Map<String, dynamic> json) =
      _$QuizChoiceImpl.fromJson;

  @override

  /// ID của lựa chọn (A/B/C/D hoặc 0/1/2/3)
  String get id;
  @override
  String get text;
  @override
  @JsonKey(ignore: true)
  _$$QuizChoiceImplCopyWith<_$QuizChoiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
