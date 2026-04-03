class PomodoroState {
  final int totalSeconds;
  final int remainingSeconds;
  final bool isRunning;

  const PomodoroState({
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.isRunning,
  });

  factory PomodoroState.initial() => const PomodoroState(
        totalSeconds: 25 * 60,
        remainingSeconds: 25 * 60,
        isRunning: false,
      );

  PomodoroState copyWith({int? totalSeconds, int? remainingSeconds, bool? isRunning}) {
    return PomodoroState(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}
