import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_stats_model.freezed.dart';
part 'dashboard_stats_model.g.dart';

/// Dữ liệu học tập theo ngày
@freezed
class DailyStudyData with _$DailyStudyData {
  const factory DailyStudyData({
    /// Số phút học trong ngày
    required int minutes,
    /// Ngày trong tuần (0 = Thứ 2, 6 = Chủ nhật)
    required int weekday,
  }) = _DailyStudyData;

  factory DailyStudyData.fromJson(Map<String, dynamic> json) =>
      _$DailyStudyDataFromJson(json);
}

/// Thống kê thời gian học trong tuần
@freezed
class StudyTimeStats with _$StudyTimeStats {
  const factory StudyTimeStats({
    /// Danh sách phút học theo từng ngày (7 phần tử: Mon-Sun)
    required List<int> dailyMinutes,
    /// Số ngày liên tiếp có >= 30 phút học
    required int streak,
    /// Tổng phút trong tuần
    required int totalMinutes,
  }) = _StudyTimeStats;

  factory StudyTimeStats.fromJson(Map<String, dynamic> json) =>
      _$StudyTimeStatsFromJson(json);
}

/// Dữ liệu điểm của một bài quiz
@freezed
class QuizScoreData with _$QuizScoreData {
  const factory QuizScoreData({
    /// ID của quiz
    required String quizId,
    /// Tên quiz
    required String quizTitle,
    /// Điểm cao nhất
    required double highestScore,
    /// Điểm trung bình
    required double averageScore,
    /// Số lần làm
    required int attemptCount,
  }) = _QuizScoreData;

  factory QuizScoreData.fromJson(Map<String, dynamic> json) =>
      _$QuizScoreDataFromJson(json);
}

/// Thống kê điểm số trắc nghiệm
@freezed
class QuizStatsData with _$QuizStatsData {
  const factory QuizStatsData({
    /// Danh sách điểm số các bài quiz
    required List<QuizScoreData> quizScores,
    /// Tỷ lệ hoàn thành tasks (0-100%)
    required double taskCompletionPercentage,
  }) = _QuizStatsData;

  factory QuizStatsData.fromJson(Map<String, dynamic> json) =>
      _$QuizStatsDataFromJson(json);
}

/// Thống kê tổng quát dashboard
@freezed
class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    /// Thống kê thời gian học
    required StudyTimeStats studyTimeStats,
    /// Thống kê điểm số quiz
    required QuizStatsData quizStats,
  }) = _DashboardStats;

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(json);
}
