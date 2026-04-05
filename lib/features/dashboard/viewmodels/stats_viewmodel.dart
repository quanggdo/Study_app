import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_stats_model.dart';
import '../repositories/dashboard_repository.dart';

/// Provider cho DashboardRepository
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

/// Provider cho thống kê tổng quát dashboard
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getDashboardStats();
});

/// Provider cho thống kê thời gian học
final studyTimeStatsProvider = FutureProvider<StudyTimeStats>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getStudyTimeStats();
});

/// Provider cho thống kê điểm số quiz
final quizStatsProvider = FutureProvider<QuizStatsData>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getQuizStats();
});

/// Provider cho mục tiêu thời gian học hàng ngày
final targetStudyTimeProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getTargetStudyTime();
});