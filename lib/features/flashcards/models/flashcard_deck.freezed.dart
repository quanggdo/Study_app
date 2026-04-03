// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flashcard_deck.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FlashcardDeck _$FlashcardDeckFromJson(Map<String, dynamic> json) {
  return _FlashcardDeck.fromJson(json);
}

/// @nodoc
mixin _$FlashcardDeck {
  String get id => throw _privateConstructorUsedError;
  String get uId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  int get cardCount => throw _privateConstructorUsedError;
  DateTime? get lastStudiedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FlashcardDeckCopyWith<FlashcardDeck> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FlashcardDeckCopyWith<$Res> {
  factory $FlashcardDeckCopyWith(
          FlashcardDeck value, $Res Function(FlashcardDeck) then) =
      _$FlashcardDeckCopyWithImpl<$Res, FlashcardDeck>;
  @useResult
  $Res call(
      {String id,
      String uId,
      String title,
      String? description,
      List<String> tags,
      int cardCount,
      DateTime? lastStudiedAt,
      DateTime createdAt,
      DateTime updatedAt,
      bool isDeleted});
}

/// @nodoc
class _$FlashcardDeckCopyWithImpl<$Res, $Val extends FlashcardDeck>
    implements $FlashcardDeckCopyWith<$Res> {
  _$FlashcardDeckCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? uId = null,
    Object? title = null,
    Object? description = freezed,
    Object? tags = null,
    Object? cardCount = null,
    Object? lastStudiedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isDeleted = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      uId: null == uId
          ? _value.uId
          : uId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      cardCount: null == cardCount
          ? _value.cardCount
          : cardCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastStudiedAt: freezed == lastStudiedAt
          ? _value.lastStudiedAt
          : lastStudiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
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
abstract class _$$FlashcardDeckImplCopyWith<$Res>
    implements $FlashcardDeckCopyWith<$Res> {
  factory _$$FlashcardDeckImplCopyWith(
          _$FlashcardDeckImpl value, $Res Function(_$FlashcardDeckImpl) then) =
      __$$FlashcardDeckImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String uId,
      String title,
      String? description,
      List<String> tags,
      int cardCount,
      DateTime? lastStudiedAt,
      DateTime createdAt,
      DateTime updatedAt,
      bool isDeleted});
}

/// @nodoc
class __$$FlashcardDeckImplCopyWithImpl<$Res>
    extends _$FlashcardDeckCopyWithImpl<$Res, _$FlashcardDeckImpl>
    implements _$$FlashcardDeckImplCopyWith<$Res> {
  __$$FlashcardDeckImplCopyWithImpl(
      _$FlashcardDeckImpl _value, $Res Function(_$FlashcardDeckImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? uId = null,
    Object? title = null,
    Object? description = freezed,
    Object? tags = null,
    Object? cardCount = null,
    Object? lastStudiedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isDeleted = null,
  }) {
    return _then(_$FlashcardDeckImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      uId: null == uId
          ? _value.uId
          : uId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      cardCount: null == cardCount
          ? _value.cardCount
          : cardCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastStudiedAt: freezed == lastStudiedAt
          ? _value.lastStudiedAt
          : lastStudiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
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
class _$FlashcardDeckImpl implements _FlashcardDeck {
  const _$FlashcardDeckImpl(
      {required this.id,
      required this.uId,
      required this.title,
      this.description,
      final List<String> tags = const <String>[],
      this.cardCount = 0,
      this.lastStudiedAt,
      required this.createdAt,
      required this.updatedAt,
      this.isDeleted = false})
      : _tags = tags;

  factory _$FlashcardDeckImpl.fromJson(Map<String, dynamic> json) =>
      _$$FlashcardDeckImplFromJson(json);

  @override
  final String id;
  @override
  final String uId;
  @override
  final String title;
  @override
  final String? description;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final int cardCount;
  @override
  final DateTime? lastStudiedAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final bool isDeleted;

  @override
  String toString() {
    return 'FlashcardDeck(id: $id, uId: $uId, title: $title, description: $description, tags: $tags, cardCount: $cardCount, lastStudiedAt: $lastStudiedAt, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FlashcardDeckImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.uId, uId) || other.uId == uId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.cardCount, cardCount) ||
                other.cardCount == cardCount) &&
            (identical(other.lastStudiedAt, lastStudiedAt) ||
                other.lastStudiedAt == lastStudiedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      uId,
      title,
      description,
      const DeepCollectionEquality().hash(_tags),
      cardCount,
      lastStudiedAt,
      createdAt,
      updatedAt,
      isDeleted);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FlashcardDeckImplCopyWith<_$FlashcardDeckImpl> get copyWith =>
      __$$FlashcardDeckImplCopyWithImpl<_$FlashcardDeckImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FlashcardDeckImplToJson(
      this,
    );
  }
}

abstract class _FlashcardDeck implements FlashcardDeck {
  const factory _FlashcardDeck(
      {required final String id,
      required final String uId,
      required final String title,
      final String? description,
      final List<String> tags,
      final int cardCount,
      final DateTime? lastStudiedAt,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final bool isDeleted}) = _$FlashcardDeckImpl;

  factory _FlashcardDeck.fromJson(Map<String, dynamic> json) =
      _$FlashcardDeckImpl.fromJson;

  @override
  String get id;
  @override
  String get uId;
  @override
  String get title;
  @override
  String? get description;
  @override
  List<String> get tags;
  @override
  int get cardCount;
  @override
  DateTime? get lastStudiedAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  bool get isDeleted;
  @override
  @JsonKey(ignore: true)
  _$$FlashcardDeckImplCopyWith<_$FlashcardDeckImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
