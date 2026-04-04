class PomodoroSessionModel {
  final String? id;
  final String uId;
  final int durationSeconds;
  final DateTime sessionDate;
  final int weekday; // 1..7

  PomodoroSessionModel({this.id, required this.uId, required this.durationSeconds, required this.sessionDate, required this.weekday});

  Map<String, dynamic> toMap() => {
        'u_id': uId,
        'duration_seconds': durationSeconds,
        'session_date': sessionDate.toIso8601String().split('T').first,
        'weekday': weekday,
        'createdAt': DateTime.now(),
      };

  factory PomodoroSessionModel.fromMap(String id, Map<String, dynamic> m) => PomodoroSessionModel(
        id: id,
        uId: m['u_id'] as String,
        durationSeconds: (m['duration_seconds'] as num).toInt(),
        sessionDate: DateTime.parse(m['session_date'] as String),
        weekday: (m['weekday'] as num).toInt(),
      );
}
// Placeholder for pomodoro/models/pomodoro_session_model.dart