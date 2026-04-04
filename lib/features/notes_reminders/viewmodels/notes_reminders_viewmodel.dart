import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_academic_assistant/core/providers/user_provider.dart';
import 'package:student_academic_assistant/features/notes_reminders/models/note_model.dart';
import 'package:student_academic_assistant/features/notes_reminders/models/task_model.dart';
import 'package:student_academic_assistant/features/notes_reminders/repositories/notes_reminders_repository.dart';

class NotesRemindersState {
  final List<TaskModel> tasks;
  final List<NoteModel> notes;
  final bool isLoading;
  final String? errorMessage;

  const NotesRemindersState({
    this.tasks = const [],
    this.notes = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  NotesRemindersState copyWith({
    List<TaskModel>? tasks,
    List<NoteModel>? notes,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotesRemindersState(
      tasks: tasks ?? this.tasks,
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class NotesRemindersViewModel extends StateNotifier<NotesRemindersState> {
  final Ref _ref;
  final NotesRemindersRepository _repository;
  final Set<String> _processingTaskIds = <String>{};
  StreamSubscription<List<TaskModel>>? _tasksSub;
  StreamSubscription<List<NoteModel>>? _notesSub;

  NotesRemindersViewModel(this._ref, this._repository)
      : super(const NotesRemindersState()) {
    _listenData();
  }

  void _listenData() {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    _tasksSub?.cancel();
    _notesSub?.cancel();

    _tasksSub = _repository.watchTasks(user.uid).listen(
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

    _notesSub = _repository.watchNotes(user.uid).listen(
      (notes) {
        state = state.copyWith(notes: notes);
      },
      onError: (error) {
        state = state.copyWith(
          errorMessage: 'Không thể tải danh sách ghi chú. Chi tiết: $error',
        );
      },
    );
  }

  Future<void> createTask({
    required String title,
    required DateTime deadline,
    required TaskPriority priority,
  }) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

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
    } catch (e, st) {
      debugPrint('createTask error: $e');
      debugPrintStack(stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tạo nhắc lịch/deadline: $e',
      );
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

  Future<void> updateTask({
    required TaskModel oldTask,
    required TaskModel newTask,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      await _repository.updateTask(oldTask: oldTask, newTask: newTask);
      state = state.copyWith(isLoading: false);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể cập nhật nhắc lịch/deadline.',
      );
    }
  }

  Future<void> createNote({
    required String subjectId,
    required String content,
  }) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final now = DateTime.now();
      final note = NoteModel(
        id: '',
        uId: user.uid,
        subjectId: subjectId.trim(),
        content: content.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await _repository.addNote(note);
      state = state.copyWith(isLoading: false);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tạo ghi chú môn học. Vui lòng thử lại.',
      );
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _repository.deleteNote(noteId);
    } catch (_) {
      state = state.copyWith(errorMessage: 'Không thể xóa ghi chú.');
    }
  }

  Future<void> updateNote(NoteModel note) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      await _repository.updateNote(
        note.copyWith(updatedAt: DateTime.now()),
      );
      state = state.copyWith(isLoading: false);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể cập nhật ghi chú.',
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  @override
  void dispose() {
    _tasksSub?.cancel();
    _notesSub?.cancel();
    super.dispose();
  }
}

final notesRemindersViewModelProvider =
    StateNotifierProvider<NotesRemindersViewModel, NotesRemindersState>((ref) {
  final repository = ref.watch(notesRemindersRepositoryProvider);
  return NotesRemindersViewModel(ref, repository);
});
