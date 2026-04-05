import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/dashboard_stats_model.dart';

/// Repository để quản lý dữ liệu thống kê dashboard
class DashboardRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DashboardRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Lấy UID của người dùng hiện tại
  String? get _userId => _auth.currentUser?.uid;

  /// Lấy thống kê thời gian học tuần hiện tại
  /// Aggregates focus_sessions data by day of week
  Future<StudyTimeStats> getStudyTimeStats() async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    const daysInWeek = 7;
    final dailyMinutes = List<int>.filled(daysInWeek, 0);

    // Fetch focus sessions for this user (no date filter in query to avoid index requirement)
    final querySnapshot = await _firestore
        .collection('focus_sessions')
        .where('u_id', isEqualTo: userId)
        .get();

    // Aggregate minutes by weekday
    final Map<int, int> dailyMap = {};
    final now = DateTime.now();
    final sevenDaysAgo = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6)); // Include today

    for (var doc in querySnapshot.docs) {
      final data = doc.data();

      // Parse session date
      DateTime? sessionDate = _parseDateTime(data['session_date']) 
          ?? _parseDateTime(data['createdAt'])
          ?? _parseDateTime(data['date']);

      if (sessionDate == null) continue;

      // Filter by date in code (avoid Firestore index requirement)
      if (sessionDate.isBefore(sevenDaysAgo)) continue;

      // Parse duration (can be in seconds or minutes)
      int minutes = _parseDuration(data);
      if (minutes == 0) continue;

      // Convert to Monday=0, Wednesday=2, Sunday=6
      final weekdayIndex = sessionDate.weekday - 1;
      dailyMap[weekdayIndex] = (dailyMap[weekdayIndex] ?? 0) + minutes;
    }

    // Fill the dailyMinutes list
    for (int i = 0; i < daysInWeek; i++) {
      dailyMinutes[i] = dailyMap[i] ?? 0;
    }

    // Calculate streak (consecutive days with >= 30 minutes from the end)
    final streak = _calculateStreak(dailyMinutes, threshold: 30);

    // Calculate total minutes
    final totalMinutes = dailyMinutes.fold<int>(0, (a, b) => a + b);

    return StudyTimeStats(
      dailyMinutes: dailyMinutes,
      streak: streak,
      totalMinutes: totalMinutes,
    );
  }

  /// Lấy thống kê điểm số quiz
  /// Aggregates quiz scores by quiz ID
  Future<QuizStatsData> getQuizStats() async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final quizScoresMap = <String, List<int>>{};
    final quizTitlesMap = <String, String>{};

    // Fetch all user_progress records for this user
    final querySnapshot = await _firestore
        .collection('user_progress')
        .where('u_id', isEqualTo: userId)
        .get();

    // Aggregate scores by quiz
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final quizId = data['quiz_id'] as String?;
      final score = (data['score'] as num?)?.toInt() ?? 0;
      final total = (data['total'] as num?)?.toInt() ?? 1;

      if (quizId == null) continue;

      if (!quizScoresMap.containsKey(quizId)) {
        quizScoresMap[quizId] = [];
        // Fetch quiz title
        try {
          final quizDoc = await _firestore.collection('quiz').doc(quizId).get();
          quizTitlesMap[quizId] = quizDoc.data()?['title'] as String? ?? 'Quiz';
        } catch (_) {
          quizTitlesMap[quizId] = 'Quiz';
        }
      }

      final percentage = total > 0 ? ((score / total) * 100).toInt() : 0;
      quizScoresMap[quizId]!.add(percentage);
    }

    // Build QuizScoreData list
    final quizScores = <QuizScoreData>[];
    for (var entry in quizScoresMap.entries) {
      final quizId = entry.key;
      final scores = entry.value;

      if (scores.isEmpty) continue;

      final highestScore = scores.reduce((a, b) => a > b ? a : b).toDouble();
      final averageScore = scores.fold<int>(0, (a, b) => a + b) / scores.length;

      quizScores.add(
        QuizScoreData(
          quizId: quizId,
          quizTitle: quizTitlesMap[quizId] ?? 'Quiz',
          highestScore: highestScore,
          averageScore: averageScore,
          attemptCount: scores.length,
        ),
      );
    }

    // Get task completion percentage
    final taskCompletionPercentage = await _getTaskCompletionPercentage(userId);

    return QuizStatsData(
      quizScores: quizScores,
      taskCompletionPercentage: taskCompletionPercentage,
    );
  }

  /// Tính tỷ lệ hoàn thành tasks
  Future<double> _getTaskCompletionPercentage(String userId) async {
    try {
      final tasksSnapshot = await _firestore
          .collection('tasks')
          .where('u_id', isEqualTo: userId)
          .get();

      if (tasksSnapshot.docs.isEmpty) return 0.0;

      int completedCount = 0;
      for (var doc in tasksSnapshot.docs) {
        final data = doc.data();
        if (data['is_completed'] == true) {
          completedCount++;
        }
      }

      return (completedCount / tasksSnapshot.docs.length) * 100;
    } catch (_) {
      return 0.0;
    }
  }

  /// Lấy tất cả thống kê dashboard
  Future<DashboardStats> getDashboardStats() async {
    final studyTimeStats = await getStudyTimeStats();
    final quizStats = await getQuizStats();

    return DashboardStats(
      studyTimeStats: studyTimeStats,
      quizStats: quizStats,
    );
  }

  /// Parse DateTime from Firestore field (can be String, Timestamp, or null)
  DateTime? _parseDateTime(dynamic value) {
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    } else if (value is Timestamp) {
      return value.toDate();
    }
    return null;
  }

  /// Parse duration from Firestore field (can be in seconds or minutes)
  int _parseDuration(Map<String, dynamic> data) {
    int minutes = 0;

    if (data['duration_seconds'] != null) {
      minutes = ((data['duration_seconds'] ?? 0) as num).toInt();
      minutes = (minutes / 60).round();
    } else if (data['duration_minutes'] != null) {
      minutes = ((data['duration_minutes'] ?? 0) as num).toInt();
    } else if (data['duration'] != null) {
      minutes = ((data['duration'] ?? 0) as num).toInt();
    }

    return minutes;
  }

  /// Calculate streak of consecutive days with minutes >= threshold
  int _calculateStreak(List<int> dailyMinutes, {int threshold = 30}) {
    int streak = 0;
    // Start from the end (most recent days) and count backwards
    for (int i = dailyMinutes.length - 1; i >= 0; i--) {
      if (dailyMinutes[i] >= threshold) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}