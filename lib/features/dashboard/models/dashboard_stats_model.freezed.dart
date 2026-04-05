// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DailyStudyData _$DailyStudyDataFromJson(Map<String, dynamic> json) {
  return _DailyStudyData.fromJson(json);
}

/// @nodoc
mixin _$DailyStudyData {
  /// Số phút học trong ngày
  int get minutes => throw _privateConstructorUsedError;

  /// Ngày trong tuần (0 = Thứ 2, 6 = Chủ nhật)
  int get weekday => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DailyStudyDataCopyWith<DailyStudyData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyStudyDataCopyWith<$Res> {
  factory $DailyStudyDataCopyWith(
          DailyStudyData value, $Res Function(DailyStudyData) then) =
      _$DailyStudyDataCopyWithImpl<$Res, DailyStudyData>;
  @useResult
  $Res call({int minutes, int weekday});
}

/// @nodoc
class _$DailyStudyDataCopyWithImpl<$Res, $Val extends DailyStudyData>
    implements $DailyStudyDataCopyWith<$Res> {
  _$DailyStudyDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minutes = null,
    Object? weekday = null,
  }) {
    return _then(_value.copyWith(
      minutes: null == minutes
          ? _value.minutes
          : minutes // ignore: cast_nullable_to_non_nullable
              as int,
      weekday: null == weekday
          ? _value.weekday
          : weekday // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyStudyDataImplCopyWith<$Res>
    implements $DailyStudyDataCopyWith<$Res> {
  factory _$$DailyStudyDataImplCopyWith(_$DailyStudyDataImpl value,
          $Res Function(_$DailyStudyDataImpl) then) =
      __$$DailyStudyDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int minutes, int weekday});
}

/// @nodoc
class __$$DailyStudyDataImplCopyWithImpl<$Res>
    extends _$DailyStudyDataCopyWithImpl<$Res, _$DailyStudyDataImpl>
    implements _$$DailyStudyDataImplCopyWith<$Res> {
  __$$DailyStudyDataImplCopyWithImpl(
      _$DailyStudyDataImpl _value, $Res Function(_$DailyStudyDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minutes = null,
    Object? weekday = null,
  }) {
    return _then(_$DailyStudyDataImpl(
      minutes: null == minutes
          ? _value.minutes
          : minutes // ignore: cast_nullable_to_non_nullable
              as int,
      weekday: null == weekday
          ? _value.weekday
          : weekday // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyStudyDataImpl implements _DailyStudyData {
  const _$DailyStudyDataImpl({required this.minutes, required this.weekday});

  factory _$DailyStudyDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyStudyDataImplFromJson(json);

  /// Số phút học trong ngày
  @override
  final int minutes;

  /// Ngày trong tuần (0 = Thứ 2, 6 = Chủ nhật)
  @override
  final int weekday;

  @override
  String toString() {
    return 'DailyStudyData(minutes: $minutes, weekday: $weekday)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyStudyDataImpl &&
            (identical(other.minutes, minutes) || other.minutes == minutes) &&
            (identical(other.weekday, weekday) || other.weekday == weekday));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, minutes, weekday);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyStudyDataImplCopyWith<_$DailyStudyDataImpl> get copyWith =>
      __$$DailyStudyDataImplCopyWithImpl<_$DailyStudyDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyStudyDataImplToJson(
      this,
    );
  }
}

abstract class _DailyStudyData implements DailyStudyData {
  const factory _DailyStudyData(
      {required final int minutes,
      required final int weekday}) = _$DailyStudyDataImpl;

  factory _DailyStudyData.fromJson(Map<String, dynamic> json) =
      _$DailyStudyDataImpl.fromJson;

  @override

  /// Số phút học trong ngày
  int get minutes;
  @override

  /// Ngày trong tuần (0 = Thứ 2, 6 = Chủ nhật)
  int get weekday;
  @override
  @JsonKey(ignore: true)
  _$$DailyStudyDataImplCopyWith<_$DailyStudyDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StudyTimeStats _$StudyTimeStatsFromJson(Map<String, dynamic> json) {
  return _StudyTimeStats.fromJson(json);
}

/// @nodoc
mixin _$StudyTimeStats {
  /// Danh sách phút học theo từng ngày (7 phần tử: Mon-Sun)
  List<int> get dailyMinutes => throw _privateConstructorUsedError;

  /// Số ngày liên tiếp có >= 30 phút học
  int get streak => throw _privateConstructorUsedError;

  /// Tổng phút trong tuần
  int get totalMinutes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StudyTimeStatsCopyWith<StudyTimeStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudyTimeStatsCopyWith<$Res> {
  factory $StudyTimeStatsCopyWith(
          StudyTimeStats value, $Res Function(StudyTimeStats) then) =
      _$StudyTimeStatsCopyWithImpl<$Res, StudyTimeStats>;
  @useResult
  $Res call({List<int> dailyMinutes, int streak, int totalMinutes});
}

/// @nodoc
class _$StudyTimeStatsCopyWithImpl<$Res, $Val extends StudyTimeStats>
    implements $StudyTimeStatsCopyWith<$Res> {
  _$StudyTimeStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dailyMinutes = null,
    Object? streak = null,
    Object? totalMinutes = null,
  }) {
    return _then(_value.copyWith(
      dailyMinutes: null == dailyMinutes
          ? _value.dailyMinutes
          : dailyMinutes // ignore: cast_nullable_to_non_nullable
              as List<int>,
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as int,
      totalMinutes: null == totalMinutes
          ? _value.totalMinutes
          : totalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StudyTimeStatsImplCopyWith<$Res>
    implements $StudyTimeStatsCopyWith<$Res> {
  factory _$$StudyTimeStatsImplCopyWith(_$StudyTimeStatsImpl value,
          $Res Function(_$StudyTimeStatsImpl) then) =
      __$$StudyTimeStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<int> dailyMinutes, int streak, int totalMinutes});
}

/// @nodoc
class __$$StudyTimeStatsImplCopyWithImpl<$Res>
    extends _$StudyTimeStatsCopyWithImpl<$Res, _$StudyTimeStatsImpl>
    implements _$$StudyTimeStatsImplCopyWith<$Res> {
  __$$StudyTimeStatsImplCopyWithImpl(
      _$StudyTimeStatsImpl _value, $Res Function(_$StudyTimeStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dailyMinutes = null,
    Object? streak = null,
    Object? totalMinutes = null,
  }) {
    return _then(_$StudyTimeStatsImpl(
      dailyMinutes: null == dailyMinutes
          ? _value._dailyMinutes
          : dailyMinutes // ignore: cast_nullable_to_non_nullable
              as List<int>,
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as int,
      totalMinutes: null == totalMinutes
          ? _value.totalMinutes
          : totalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StudyTimeStatsImpl implements _StudyTimeStats {
  const _$StudyTimeStatsImpl(
      {required final List<int> dailyMinutes,
      required this.streak,
      required this.totalMinutes})
      : _dailyMinutes = dailyMinutes;

  factory _$StudyTimeStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudyTimeStatsImplFromJson(json);

  /// Danh sách phút học theo từng ngày (7 phần tử: Mon-Sun)
  final List<int> _dailyMinutes;

  /// Danh sách phút học theo từng ngày (7 phần tử: Mon-Sun)
  @override
  List<int> get dailyMinutes {
    if (_dailyMinutes is EqualUnmodifiableListView) return _dailyMinutes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dailyMinutes);
  }

  /// Số ngày liên tiếp có >= 30 phút học
  @override
  final int streak;

  /// Tổng phút trong tuần
  @override
  final int totalMinutes;

  @override
  String toString() {
    return 'StudyTimeStats(dailyMinutes: $dailyMinutes, streak: $streak, totalMinutes: $totalMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudyTimeStatsImpl &&
            const DeepCollectionEquality()
                .equals(other._dailyMinutes, _dailyMinutes) &&
            (identical(other.streak, streak) || other.streak == streak) &&
            (identical(other.totalMinutes, totalMinutes) ||
                other.totalMinutes == totalMinutes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_dailyMinutes), streak, totalMinutes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StudyTimeStatsImplCopyWith<_$StudyTimeStatsImpl> get copyWith =>
      __$$StudyTimeStatsImplCopyWithImpl<_$StudyTimeStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudyTimeStatsImplToJson(
      this,
    );
  }
}

abstract class _StudyTimeStats implements StudyTimeStats {
  const factory _StudyTimeStats(
      {required final List<int> dailyMinutes,
      required final int streak,
      required final int totalMinutes}) = _$StudyTimeStatsImpl;

  factory _StudyTimeStats.fromJson(Map<String, dynamic> json) =
      _$StudyTimeStatsImpl.fromJson;

  @override

  /// Danh sách phút học theo từng ngày (7 phần tử: Mon-Sun)
  List<int> get dailyMinutes;
  @override

  /// Số ngày liên tiếp có >= 30 phút học
  int get streak;
  @override

  /// Tổng phút trong tuần
  int get totalMinutes;
  @override
  @JsonKey(ignore: true)
  _$$StudyTimeStatsImplCopyWith<_$StudyTimeStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QuizScoreData _$QuizScoreDataFromJson(Map<String, dynamic> json) {
  return _QuizScoreData.fromJson(json);
}

/// @nodoc
mixin _$QuizScoreData {
  /// ID của quiz
  String get quizId => throw _privateConstructorUsedError;

  /// Tên quiz
  String get quizTitle => throw _privateConstructorUsedError;

  /// Điểm cao nhất
  double get highestScore => throw _privateConstructorUsedError;

  /// Điểm trung bình
  double get averageScore => throw _privateConstructorUsedError;

  /// Số lần làm
  int get attemptCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuizScoreDataCopyWith<QuizScoreData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuizScoreDataCopyWith<$Res> {
  factory $QuizScoreDataCopyWith(
          QuizScoreData value, $Res Function(QuizScoreData) then) =
      _$QuizScoreDataCopyWithImpl<$Res, QuizScoreData>;
  @useResult
  $Res call(
      {String quizId,
      String quizTitle,
      double highestScore,
      double averageScore,
      int attemptCount});
}

/// @nodoc
class _$QuizScoreDataCopyWithImpl<$Res, $Val extends QuizScoreData>
    implements $QuizScoreDataCopyWith<$Res> {
  _$QuizScoreDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? quizId = null,
    Object? quizTitle = null,
    Object? highestScore = null,
    Object? averageScore = null,
    Object? attemptCount = null,
  }) {
    return _then(_value.copyWith(
      quizId: null == quizId
          ? _value.quizId
          : quizId // ignore: cast_nullable_to_non_nullable
              as String,
      quizTitle: null == quizTitle
          ? _value.quizTitle
          : quizTitle // ignore: cast_nullable_to_non_nullable
              as String,
      highestScore: null == highestScore
          ? _value.highestScore
          : highestScore // ignore: cast_nullable_to_non_nullable
              as double,
      averageScore: null == averageScore
          ? _value.averageScore
          : averageScore // ignore: cast_nullable_to_non_nullable
              as double,
      attemptCount: null == attemptCount
          ? _value.attemptCount
          : attemptCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuizScoreDataImplCopyWith<$Res>
    implements $QuizScoreDataCopyWith<$Res> {
  factory _$$QuizScoreDataImplCopyWith(
          _$QuizScoreDataImpl value, $Res Function(_$QuizScoreDataImpl) then) =
      __$$QuizScoreDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String quizId,
      String quizTitle,
      double highestScore,
      double averageScore,
      int attemptCount});
}

/// @nodoc
class __$$QuizScoreDataImplCopyWithImpl<$Res>
    extends _$QuizScoreDataCopyWithImpl<$Res, _$QuizScoreDataImpl>
    implements _$$QuizScoreDataImplCopyWith<$Res> {
  __$$QuizScoreDataImplCopyWithImpl(
      _$QuizScoreDataImpl _value, $Res Function(_$QuizScoreDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? quizId = null,
    Object? quizTitle = null,
    Object? highestScore = null,
    Object? averageScore = null,
    Object? attemptCount = null,
  }) {
    return _then(_$QuizScoreDataImpl(
      quizId: null == quizId
          ? _value.quizId
          : quizId // ignore: cast_nullable_to_non_nullable
              as String,
      quizTitle: null == quizTitle
          ? _value.quizTitle
          : quizTitle // ignore: cast_nullable_to_non_nullable
              as String,
      highestScore: null == highestScore
          ? _value.highestScore
          : highestScore // ignore: cast_nullable_to_non_nullable
              as double,
      averageScore: null == averageScore
          ? _value.averageScore
          : averageScore // ignore: cast_nullable_to_non_nullable
              as double,
      attemptCount: null == attemptCount
          ? _value.attemptCount
          : attemptCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuizScoreDataImpl implements _QuizScoreData {
  const _$QuizScoreDataImpl(
      {required this.quizId,
      required this.quizTitle,
      required this.highestScore,
      required this.averageScore,
      required this.attemptCount});

  factory _$QuizScoreDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuizScoreDataImplFromJson(json);

  /// ID của quiz
  @override
  final String quizId;

  /// Tên quiz
  @override
  final String quizTitle;

  /// Điểm cao nhất
  @override
  final double highestScore;

  /// Điểm trung bình
  @override
  final double averageScore;

  /// Số lần làm
  @override
  final int attemptCount;

  @override
  String toString() {
    return 'QuizScoreData(quizId: $quizId, quizTitle: $quizTitle, highestScore: $highestScore, averageScore: $averageScore, attemptCount: $attemptCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuizScoreDataImpl &&
            (identical(other.quizId, quizId) || other.quizId == quizId) &&
            (identical(other.quizTitle, quizTitle) ||
                other.quizTitle == quizTitle) &&
            (identical(other.highestScore, highestScore) ||
                other.highestScore == highestScore) &&
            (identical(other.averageScore, averageScore) ||
                other.averageScore == averageScore) &&
            (identical(other.attemptCount, attemptCount) ||
                other.attemptCount == attemptCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, quizId, quizTitle, highestScore, averageScore, attemptCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuizScoreDataImplCopyWith<_$QuizScoreDataImpl> get copyWith =>
      __$$QuizScoreDataImplCopyWithImpl<_$QuizScoreDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuizScoreDataImplToJson(
      this,
    );
  }
}

abstract class _QuizScoreData implements QuizScoreData {
  const factory _QuizScoreData(
      {required final String quizId,
      required final String quizTitle,
      required final double highestScore,
      required final double averageScore,
      required final int attemptCount}) = _$QuizScoreDataImpl;

  factory _QuizScoreData.fromJson(Map<String, dynamic> json) =
      _$QuizScoreDataImpl.fromJson;

  @override

  /// ID của quiz
  String get quizId;
  @override

  /// Tên quiz
  String get quizTitle;
  @override

  /// Điểm cao nhất
  double get highestScore;
  @override

  /// Điểm trung bình
  double get averageScore;
  @override

  /// Số lần làm
  int get attemptCount;
  @override
  @JsonKey(ignore: true)
  _$$QuizScoreDataImplCopyWith<_$QuizScoreDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QuizStatsData _$QuizStatsDataFromJson(Map<String, dynamic> json) {
  return _QuizStatsData.fromJson(json);
}

/// @nodoc
mixin _$QuizStatsData {
  /// Danh sách điểm số các bài quiz
  List<QuizScoreData> get quizScores => throw _privateConstructorUsedError;

  /// Tỷ lệ hoàn thành tasks (0-100%)
  double get taskCompletionPercentage => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuizStatsDataCopyWith<QuizStatsData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuizStatsDataCopyWith<$Res> {
  factory $QuizStatsDataCopyWith(
          QuizStatsData value, $Res Function(QuizStatsData) then) =
      _$QuizStatsDataCopyWithImpl<$Res, QuizStatsData>;
  @useResult
  $Res call({List<QuizScoreData> quizScores, double taskCompletionPercentage});
}

/// @nodoc
class _$QuizStatsDataCopyWithImpl<$Res, $Val extends QuizStatsData>
    implements $QuizStatsDataCopyWith<$Res> {
  _$QuizStatsDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? quizScores = null,
    Object? taskCompletionPercentage = null,
  }) {
    return _then(_value.copyWith(
      quizScores: null == quizScores
          ? _value.quizScores
          : quizScores // ignore: cast_nullable_to_non_nullable
              as List<QuizScoreData>,
      taskCompletionPercentage: null == taskCompletionPercentage
          ? _value.taskCompletionPercentage
          : taskCompletionPercentage // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuizStatsDataImplCopyWith<$Res>
    implements $QuizStatsDataCopyWith<$Res> {
  factory _$$QuizStatsDataImplCopyWith(
          _$QuizStatsDataImpl value, $Res Function(_$QuizStatsDataImpl) then) =
      __$$QuizStatsDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<QuizScoreData> quizScores, double taskCompletionPercentage});
}

/// @nodoc
class __$$QuizStatsDataImplCopyWithImpl<$Res>
    extends _$QuizStatsDataCopyWithImpl<$Res, _$QuizStatsDataImpl>
    implements _$$QuizStatsDataImplCopyWith<$Res> {
  __$$QuizStatsDataImplCopyWithImpl(
      _$QuizStatsDataImpl _value, $Res Function(_$QuizStatsDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? quizScores = null,
    Object? taskCompletionPercentage = null,
  }) {
    return _then(_$QuizStatsDataImpl(
      quizScores: null == quizScores
          ? _value._quizScores
          : quizScores // ignore: cast_nullable_to_non_nullable
              as List<QuizScoreData>,
      taskCompletionPercentage: null == taskCompletionPercentage
          ? _value.taskCompletionPercentage
          : taskCompletionPercentage // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuizStatsDataImpl implements _QuizStatsData {
  const _$QuizStatsDataImpl(
      {required final List<QuizScoreData> quizScores,
      required this.taskCompletionPercentage})
      : _quizScores = quizScores;

  factory _$QuizStatsDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuizStatsDataImplFromJson(json);

  /// Danh sách điểm số các bài quiz
  final List<QuizScoreData> _quizScores;

  /// Danh sách điểm số các bài quiz
  @override
  List<QuizScoreData> get quizScores {
    if (_quizScores is EqualUnmodifiableListView) return _quizScores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_quizScores);
  }

  /// Tỷ lệ hoàn thành tasks (0-100%)
  @override
  final double taskCompletionPercentage;

  @override
  String toString() {
    return 'QuizStatsData(quizScores: $quizScores, taskCompletionPercentage: $taskCompletionPercentage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuizStatsDataImpl &&
            const DeepCollectionEquality()
                .equals(other._quizScores, _quizScores) &&
            (identical(
                    other.taskCompletionPercentage, taskCompletionPercentage) ||
                other.taskCompletionPercentage == taskCompletionPercentage));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_quizScores),
      taskCompletionPercentage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuizStatsDataImplCopyWith<_$QuizStatsDataImpl> get copyWith =>
      __$$QuizStatsDataImplCopyWithImpl<_$QuizStatsDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuizStatsDataImplToJson(
      this,
    );
  }
}

abstract class _QuizStatsData implements QuizStatsData {
  const factory _QuizStatsData(
      {required final List<QuizScoreData> quizScores,
      required final double taskCompletionPercentage}) = _$QuizStatsDataImpl;

  factory _QuizStatsData.fromJson(Map<String, dynamic> json) =
      _$QuizStatsDataImpl.fromJson;

  @override

  /// Danh sách điểm số các bài quiz
  List<QuizScoreData> get quizScores;
  @override

  /// Tỷ lệ hoàn thành tasks (0-100%)
  double get taskCompletionPercentage;
  @override
  @JsonKey(ignore: true)
  _$$QuizStatsDataImplCopyWith<_$QuizStatsDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) {
  return _DashboardStats.fromJson(json);
}

/// @nodoc
mixin _$DashboardStats {
  /// Thống kê thời gian học
  StudyTimeStats get studyTimeStats => throw _privateConstructorUsedError;

  /// Thống kê điểm số quiz
  QuizStatsData get quizStats => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DashboardStatsCopyWith<DashboardStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardStatsCopyWith<$Res> {
  factory $DashboardStatsCopyWith(
          DashboardStats value, $Res Function(DashboardStats) then) =
      _$DashboardStatsCopyWithImpl<$Res, DashboardStats>;
  @useResult
  $Res call({StudyTimeStats studyTimeStats, QuizStatsData quizStats});

  $StudyTimeStatsCopyWith<$Res> get studyTimeStats;
  $QuizStatsDataCopyWith<$Res> get quizStats;
}

/// @nodoc
class _$DashboardStatsCopyWithImpl<$Res, $Val extends DashboardStats>
    implements $DashboardStatsCopyWith<$Res> {
  _$DashboardStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studyTimeStats = null,
    Object? quizStats = null,
  }) {
    return _then(_value.copyWith(
      studyTimeStats: null == studyTimeStats
          ? _value.studyTimeStats
          : studyTimeStats // ignore: cast_nullable_to_non_nullable
              as StudyTimeStats,
      quizStats: null == quizStats
          ? _value.quizStats
          : quizStats // ignore: cast_nullable_to_non_nullable
              as QuizStatsData,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $StudyTimeStatsCopyWith<$Res> get studyTimeStats {
    return $StudyTimeStatsCopyWith<$Res>(_value.studyTimeStats, (value) {
      return _then(_value.copyWith(studyTimeStats: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $QuizStatsDataCopyWith<$Res> get quizStats {
    return $QuizStatsDataCopyWith<$Res>(_value.quizStats, (value) {
      return _then(_value.copyWith(quizStats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DashboardStatsImplCopyWith<$Res>
    implements $DashboardStatsCopyWith<$Res> {
  factory _$$DashboardStatsImplCopyWith(_$DashboardStatsImpl value,
          $Res Function(_$DashboardStatsImpl) then) =
      __$$DashboardStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({StudyTimeStats studyTimeStats, QuizStatsData quizStats});

  @override
  $StudyTimeStatsCopyWith<$Res> get studyTimeStats;
  @override
  $QuizStatsDataCopyWith<$Res> get quizStats;
}

/// @nodoc
class __$$DashboardStatsImplCopyWithImpl<$Res>
    extends _$DashboardStatsCopyWithImpl<$Res, _$DashboardStatsImpl>
    implements _$$DashboardStatsImplCopyWith<$Res> {
  __$$DashboardStatsImplCopyWithImpl(
      _$DashboardStatsImpl _value, $Res Function(_$DashboardStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studyTimeStats = null,
    Object? quizStats = null,
  }) {
    return _then(_$DashboardStatsImpl(
      studyTimeStats: null == studyTimeStats
          ? _value.studyTimeStats
          : studyTimeStats // ignore: cast_nullable_to_non_nullable
              as StudyTimeStats,
      quizStats: null == quizStats
          ? _value.quizStats
          : quizStats // ignore: cast_nullable_to_non_nullable
              as QuizStatsData,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardStatsImpl implements _DashboardStats {
  const _$DashboardStatsImpl(
      {required this.studyTimeStats, required this.quizStats});

  factory _$DashboardStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardStatsImplFromJson(json);

  /// Thống kê thời gian học
  @override
  final StudyTimeStats studyTimeStats;

  /// Thống kê điểm số quiz
  @override
  final QuizStatsData quizStats;

  @override
  String toString() {
    return 'DashboardStats(studyTimeStats: $studyTimeStats, quizStats: $quizStats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardStatsImpl &&
            (identical(other.studyTimeStats, studyTimeStats) ||
                other.studyTimeStats == studyTimeStats) &&
            (identical(other.quizStats, quizStats) ||
                other.quizStats == quizStats));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, studyTimeStats, quizStats);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardStatsImplCopyWith<_$DashboardStatsImpl> get copyWith =>
      __$$DashboardStatsImplCopyWithImpl<_$DashboardStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardStatsImplToJson(
      this,
    );
  }
}

abstract class _DashboardStats implements DashboardStats {
  const factory _DashboardStats(
      {required final StudyTimeStats studyTimeStats,
      required final QuizStatsData quizStats}) = _$DashboardStatsImpl;

  factory _DashboardStats.fromJson(Map<String, dynamic> json) =
      _$DashboardStatsImpl.fromJson;

  @override

  /// Thống kê thời gian học
  StudyTimeStats get studyTimeStats;
  @override

  /// Thống kê điểm số quiz
  QuizStatsData get quizStats;
  @override
  @JsonKey(ignore: true)
  _$$DashboardStatsImplCopyWith<_$DashboardStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
