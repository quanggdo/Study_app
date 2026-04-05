import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/viewmodels/stats_viewmodel.dart';
import '../models/pomodoro_session_model.dart';
import '../models/pomodoro_state.dart';

final pomodoroViewModelProvider = StateNotifierProvider<PomodoroViewModel, PomodoroState>(
  (ref) => PomodoroViewModel(ref),
);

class PomodoroViewModel extends StateNotifier<PomodoroState> {
  final Ref _ref;
  Timer? _timer;

  PomodoroViewModel(this._ref) : super(PomodoroState.initial());

  void setDuration({required int hours, required int minutes}) {
    final total = hours * 3600 + minutes * 60;
    final newTotal = total > 0 ? total : state.totalSeconds;
    state = state.copyWith(totalSeconds: newTotal, remainingSeconds: newTotal, status: PomodoroStatus.ready);
    _timer?.cancel();
  }

  void start() {
    if (state.remainingSeconds <= 0) return;
    if (state.status == PomodoroStatus.running) return;
    state = state.copyWith(status: PomodoroStatus.running);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final next = state.remainingSeconds - 1;
      if (next <= 0) {
        _timer?.cancel();
        state = state.copyWith(remainingSeconds: 0, status: PomodoroStatus.finished);
        // on completion, persist the full session
        await _saveSessionElapsed(state.totalSeconds);
      } else {
        state = state.copyWith(remainingSeconds: next);
      }
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(status: PomodoroStatus.paused);
    final elapsed = state.totalSeconds - state.remainingSeconds;
    if (elapsed > 0) {
      _saveSessionElapsed(elapsed);
    }
  }

  void reset() {
    // when resetting, persist elapsed before resetting
    final elapsed = state.totalSeconds - state.remainingSeconds;
    if (elapsed > 0) {
      _saveSessionElapsed(elapsed);
    }
    _timer?.cancel();
    state = state.copyWith(remainingSeconds: state.totalSeconds, status: PomodoroStatus.finished);
  }

  Future<void> _saveSessionElapsed(int seconds) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final now = DateTime.now();
      final session = PomodoroSessionModel(uId: user.uid, durationSeconds: seconds, sessionDate: now, weekday: now.weekday);
      final col = FirebaseFirestore.instance.collection('focus_sessions');
      await col.add(session.toMap());
      
      // Invalidate providers để refresh data
      _ref.invalidate(studyTimeStatsProvider);
      _ref.invalidate(targetStudyTimeProvider);
    } catch (e) {
      // ignore errors here; caller may show UI
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
