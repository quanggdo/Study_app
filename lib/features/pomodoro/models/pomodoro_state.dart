enum PomodoroStatus { finished, ready, running, paused }

class PomodoroState {
  final int totalSeconds;
  final int remainingSeconds;
  final PomodoroStatus status;

  const PomodoroState({required this.totalSeconds, required this.remainingSeconds, required this.status});

  factory PomodoroState.initial() => const PomodoroState(totalSeconds: 1500, remainingSeconds: 1500, status: PomodoroStatus.ready);

  PomodoroState copyWith({int? totalSeconds, int? remainingSeconds, PomodoroStatus? status}) {
    return PomodoroState(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      status: status ?? this.status,
    );
  }
}
