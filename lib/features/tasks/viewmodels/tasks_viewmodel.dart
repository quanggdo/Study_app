import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_academic_assistant/core/providers/user_provider.dart';
import 'package:student_academic_assistant/features/dashboard/viewmodels/stats_viewmodel.dart';
import 'package:student_academic_assistant/features/tasks/models/task_model.dart';
import 'package:student_academic_assistant/features/tasks/repositories/tasks_repository.dart';

class TasksState {
  final List<TaskModel> tasks;
  final bool isLoading;
  final String? errorMessage;

  const TasksState({
    this.tasks = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  TasksState copyWith({
    List<TaskModel>? tasks,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class TasksViewModel extends StateNotifier<TasksState> {
  final Ref _ref;
  final TasksRepository _repository;
  final Set<String> _processingTaskIds = <String>{};
  StreamSubscription<List<TaskModel>>? _tasksSub;

  TasksViewModel(this._ref, this._repository) : super(const TasksState()) {
    _listenAuthChanges();
    _listenTasks();
  }

  void _listenAuthChanges() {
    _ref.listen(currentUserProvider, (previous, next) {
      final String? previousUid = previous?.uid;
      final String? nextUid = next?.uid;

      if (previousUid == nextUid) {
        return;
      }

      if (nextUid == null) {
        _tasksSub?.cancel();
        _tasksSub = null;
        state = state.copyWith(
          tasks: const <TaskModel>[],
          isLoading: false,
          errorMessage: null,
        );
        return;
      }

      _bindTasksStream(nextUid);
    });
  }

  void _listenTasks() {
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      _tasksSub?.cancel();
      _tasksSub = null;
      state = state.copyWith(tasks: const <TaskModel>[]);
      return;
    }

    _bindTasksStream(user.uid);
  }

  void _bindTasksStream(String uid) {
    _tasksSub?.cancel();
    _tasksSub = _repository.watchTasks(uid).listen(
      (tasks) {
        state = state.copyWith(tasks: tasks);
      },
      onError: (error) {
        state = state.copyWith(
          errorMessage:
              'Không thể tải task. Nếu dùng where + orderBy, hãy tạo Firestore index. Chi tiết: $error',
        );
      },
    );
  }

  Future<bool> createTask({
    required String title,
    required DateTime deadline,
    required TaskPriority priority,
  }) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return false;

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final task = TaskModel(
        id: '',
        uId: user.uid,
        title: title.trim(),
        deadline: deadline,
        isCompleted: false,
        reminderId: 0,
        priority: priority,
        createdAt: DateTime.now(),
      );

      await _repository.addTask(task);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e, st) {
      debugPrint('createTask error: $e');
      debugPrintStack(stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tạo nhắc lịch/deadline: $e',
      );
      return false;
    }
  }

  Future<void> toggleTask(TaskModel task) async {
    if (_processingTaskIds.contains(task.id)) {
      return;
    }

    _processingTaskIds.add(task.id);
    final expectedStatus = !task.isCompleted;
    final previousTasks = state.tasks;
    final toggledTasks = state.tasks
        .map((item) => item.id == task.id
            ? item.copyWith(isCompleted: expectedStatus)
            : item)
        .toList();

    state = state.copyWith(tasks: toggledTasks, errorMessage: null);

    try {
      final persistedStatus = await _repository.toggleTaskComplete(task);
      if (persistedStatus != expectedStatus) {
        final syncedTasks = state.tasks
            .map((item) => item.id == task.id
                ? item.copyWith(isCompleted: persistedStatus)
                : item)
            .toList();
        state = state.copyWith(tasks: syncedTasks);
      }
      // Invalidate tất cả providers để refresh dashboard + hôm nay stats
      _ref.invalidate(dashboardStatsProvider);
      _ref.invalidate(studyTimeStatsProvider);
      _ref.invalidate(quizStatsProvider);
    } catch (e, st) {
      debugPrint('toggleTask error: $e');
      debugPrintStack(stackTrace: st);
      state = state.copyWith(
        tasks: previousTasks,
        errorMessage: 'Không thể cập nhật trạng thái công việc: $e',
      );
    } finally {
      _processingTaskIds.remove(task.id);
    }
  }

  Future<void> deleteTask(TaskModel task) async {
    try {
      await _repository.deleteTask(task);
    } catch (_) {
      state = state.copyWith(errorMessage: 'Không thể xóa nhắc nhở.');
    }
  }

  Future<bool> updateTask({
    required TaskModel oldTask,
    required TaskModel newTask,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final TaskModel reactivatedTask = newTask.copyWith(isCompleted: false);
      await _repository.updateTask(
        oldTask: oldTask,
        newTask: reactivatedTask,
      );
      state = state.copyWith(isLoading: false);
      // Invalidate tất cả providers để refresh dashboard + hôm nay stats
      _ref.invalidate(dashboardStatsProvider);
      _ref.invalidate(studyTimeStatsProvider);
      _ref.invalidate(quizStatsProvider);
      return true;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể cập nhật nhắc lịch/deadline.',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  @override
  void dispose() {
    _tasksSub?.cancel();
    super.dispose();
  }
}

final tasksViewModelProvider =
    StateNotifierProvider<TasksViewModel, TasksState>((ref) {
  final repository = ref.watch(tasksRepositoryProvider);
  return TasksViewModel(ref, repository);
});
