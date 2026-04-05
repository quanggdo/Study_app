// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyStudyDataImpl _$$DailyStudyDataImplFromJson(Map<String, dynamic> json) =>
    _$DailyStudyDataImpl(
      minutes: (json['minutes'] as num).toInt(),
      weekday: (json['weekday'] as num).toInt(),
    );

Map<String, dynamic> _$$DailyStudyDataImplToJson(
        _$DailyStudyDataImpl instance) =>
    <String, dynamic>{
      'minutes': instance.minutes,
      'weekday': instance.weekday,
    };

_$StudyTimeStatsImpl _$$StudyTimeStatsImplFromJson(Map<String, dynamic> json) =>
    _$StudyTimeStatsImpl(
      dailyMinutes: (json['dailyMinutes'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      streak: (json['streak'] as num).toInt(),
      totalMinutes: (json['totalMinutes'] as num).toInt(),
    );

Map<String, dynamic> _$$StudyTimeStatsImplToJson(
        _$StudyTimeStatsImpl instance) =>
    <String, dynamic>{
      'dailyMinutes': instance.dailyMinutes,
      'streak': instance.streak,
      'totalMinutes': instance.totalMinutes,
    };

_$QuizScoreDataImpl _$$QuizScoreDataImplFromJson(Map<String, dynamic> json) =>
    _$QuizScoreDataImpl(
      quizId: json['quizId'] as String,
      quizTitle: json['quizTitle'] as String,
      highestScore: (json['highestScore'] as num).toDouble(),
      averageScore: (json['averageScore'] as num).toDouble(),
      attemptCount: (json['attemptCount'] as num).toInt(),
    );

Map<String, dynamic> _$$QuizScoreDataImplToJson(_$QuizScoreDataImpl instance) =>
    <String, dynamic>{
      'quizId': instance.quizId,
      'quizTitle': instance.quizTitle,
      'highestScore': instance.highestScore,
      'averageScore': instance.averageScore,
      'attemptCount': instance.attemptCount,
    };

_$QuizStatsDataImpl _$$QuizStatsDataImplFromJson(Map<String, dynamic> json) =>
    _$QuizStatsDataImpl(
      quizScores: (json['quizScores'] as List<dynamic>)
          .map((e) => QuizScoreData.fromJson(e as Map<String, dynamic>))
          .toList(),
      taskCompletionPercentage:
          (json['taskCompletionPercentage'] as num).toDouble(),
    );

Map<String, dynamic> _$$QuizStatsDataImplToJson(_$QuizStatsDataImpl instance) =>
    <String, dynamic>{
      'quizScores': instance.quizScores,
      'taskCompletionPercentage': instance.taskCompletionPercentage,
    };

_$DashboardStatsImpl _$$DashboardStatsImplFromJson(Map<String, dynamic> json) =>
    _$DashboardStatsImpl(
      studyTimeStats: StudyTimeStats.fromJson(
          json['studyTimeStats'] as Map<String, dynamic>),
      quizStats:
          QuizStatsData.fromJson(json['quizStats'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$DashboardStatsImplToJson(
        _$DashboardStatsImpl instance) =>
    <String, dynamic>{
      'studyTimeStats': instance.studyTimeStats,
      'quizStats': instance.quizStats,
    };
