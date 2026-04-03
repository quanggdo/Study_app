import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pomodoro_state.dart';

final pomodoroViewModelProvider = StateNotifierProvider<PomodoroViewModel, PomodoroState>(
  (ref) => PomodoroViewModel(),
);

class PomodoroViewModel extends StateNotifier<PomodoroState> {
  Timer? _timer;

  PomodoroViewModel() : super(PomodoroState.initial());

  void setDuration({required int hours, required int minutes}) {
    final total = hours * 3600 + minutes * 60;
    final newTotal = total > 0 ? total : state.totalSeconds;
    state = state.copyWith(totalSeconds: newTotal, remainingSeconds: newTotal, isRunning: false);
    _timer?.cancel();
  }

  void start() {
    if (state.remainingSeconds <= 0) return;
    if (state.isRunning) return;
    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = state.remainingSeconds - 1;
      if (next <= 0) {
        _timer?.cancel();
        state = state.copyWith(remainingSeconds: 0, isRunning: false);
      } else {
        state = state.copyWith(remainingSeconds: next);
      }
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    _timer?.cancel();
    state = state.copyWith(remainingSeconds: state.totalSeconds, isRunning: false);
  }

  double get progress {
    if (state.totalSeconds == 0) return 0.0;
    final elapsed = state.totalSeconds - state.remainingSeconds;
    return (elapsed / state.totalSeconds).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
