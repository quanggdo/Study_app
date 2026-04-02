import 'dart:math';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/user_provider.dart';
import '../models/note_model.dart';
import '../models/task_model.dart';
import '../repositories/notes_repository.dart';

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

class NotesViewModel extends StateNotifier<NotesRemindersState> {
  final Ref _ref;
  final NotesRepository _repository;
  StreamSubscription<List<TaskModel>>? _tasksSub;
  StreamSubscription<List<NoteModel>>? _notesSub;

  NotesViewModel(this._ref, this._repository)
      : super(const NotesRemindersState()) {
    _listenData();
  }

  void _listenData() {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    _tasksSub?.cancel();
    _notesSub?.cancel();

    _tasksSub = _repository.watchTasks(user.uid).listen((tasks) {
      state = state.copyWith(tasks: tasks);
    });

    _notesSub = _repository.watchNotes(user.uid).listen((notes) {
      state = state.copyWith(notes: notes);
    });
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
        reminderId: _generateReminderId(deadline),
        priority: priority,
        createdAt: DateTime.now(),
      );

      await _repository.addTask(task);
      state = state.copyWith(isLoading: false);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tạo nhắc lịch/deadline. Vui lòng thử lại.',
      );
    }
  }

  Future<void> toggleTask(TaskModel task) async {
    try {
      await _repository.toggleTaskComplete(task);
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Không thể cập nhật trạng thái công việc.',
      );
    }
  }

  Future<void> deleteTask(TaskModel task) async {
    try {
      await _repository.deleteTask(task);
    } catch (_) {
      state = state.copyWith(errorMessage: 'Không thể xóa nhắc nhở.');
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      await _repository.updateTask(task);
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

  int _generateReminderId(DateTime date) {
    final seed = date.microsecondsSinceEpoch ^ Random().nextInt(1 << 20);
    return seed & 0x7fffffff;
  }
}

final notesViewModelProvider =
    StateNotifierProvider<NotesViewModel, NotesRemindersState>((ref) {
  final repository = ref.watch(notesRepositoryProvider);
  return NotesViewModel(ref, repository);
});
