import 'package:student_academic_assistant/features/pomodoro/services/dnd_service.dart';

enum PomodoroStatus { finished, ready, running, paused }

class PomodoroState {
  final int totalSeconds;
  final int remainingSeconds;
  final PomodoroStatus status;

  const PomodoroState({required this.totalSeconds, required this.remainingSeconds, required this.status});

  factory PomodoroState.initial() => const PomodoroState(totalSeconds: 1500, remainingSeconds: 1500, status: PomodoroStatus.ready);

  PomodoroState copyWith({int? totalSeconds, int? remainingSeconds, PomodoroStatus? status}) {
    final newStatus = status ?? this.status;
    final newState = PomodoroState(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      status: newStatus,
    );

    // Trigger DND when status changes to running/paused, or disable otherwise.
    if (newStatus != this.status) {
      if (newStatus == PomodoroStatus.running || newStatus == PomodoroStatus.paused) {
        DndService.setDnd(true);
      } else {
        DndService.setDnd(false);
      }
    }

    return newState;
  }
}
