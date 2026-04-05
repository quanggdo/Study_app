import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_academic_assistant/core/providers/user_provider.dart';
import 'package:student_academic_assistant/features/notes/models/note_model.dart';
import 'package:student_academic_assistant/features/notes/repositories/notes_repository.dart';
import 'package:student_academic_assistant/features/notes/services/note_ai_service.dart';

class NotesState {
  final List<NoteModel> notes;
  final bool isLoading;
  final String? errorMessage;

  const NotesState({
    this.notes = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  NotesState copyWith({
    List<NoteModel>? notes,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class NotesViewModel extends StateNotifier<NotesState> {
  final Ref _ref;
  final NotesRepository _repository;
  final NoteAiService _noteAiService;
  StreamSubscription<List<NoteModel>>? _notesSub;

  NotesViewModel(this._ref, this._repository, this._noteAiService)
      : super(const NotesState()) {
    _listenAuthChanges();
    _listenNotes();
  }

  void _listenAuthChanges() {
    _ref.listen(currentUserProvider, (previous, next) {
      final String? previousUid = previous?.uid;
      final String? nextUid = next?.uid;

      if (previousUid == nextUid) {
        return;
      }

      if (nextUid == null) {
        _notesSub?.cancel();
        _notesSub = null;
        state = state.copyWith(
          notes: const <NoteModel>[],
          isLoading: false,
          errorMessage: null,
        );
        return;
      }

      _bindNotesStream(nextUid);
    });
  }

  void _listenNotes() {
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      _notesSub?.cancel();
      _notesSub = null;
      state = state.copyWith(notes: const <NoteModel>[]);
      return;
    }

    _bindNotesStream(user.uid);
  }

  void _bindNotesStream(String uid) {
    _notesSub?.cancel();
    _notesSub = _repository.watchNotes(uid).listen(
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

  Future<void> createNote({
    required String subjectName,
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
        subjectName: subjectName.trim(),
        content: content.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await _repository.addNote(note);
      state = state.copyWith(isLoading: false);
    } catch (e, st) {
      debugPrint('createNote error: $e');
      debugPrintStack(stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tạo ghi chú môn học. Vui lòng thử lại.',
      );
    }
  }

  Future<void> createNoteFromAsrInput({
    required String subjectHint,
    String transcript = '',
    PlatformFile? audioFile,
  }) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final String cleanTranscript = transcript.trim();
    if (audioFile == null && cleanTranscript.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Bạn chưa cung cấp giọng nói hoặc file ghi âm.',
      );
      return;
    }

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final aiResult = audioFile != null
          ? await _noteAiService.buildNoteFromAudioFile(
              file: audioFile,
              subjectHint: subjectHint,
            )
          : await _noteAiService.buildNoteFromTranscript(
              transcript: cleanTranscript,
              subjectHint: subjectHint,
            );

      final now = DateTime.now();
      final String finalSubjectName = aiResult.subjectName.isEmpty
          ? subjectHint.trim()
          : aiResult.subjectName;

      final note = NoteModel(
        id: '',
        uId: user.uid,
        subjectName: finalSubjectName,
        content: aiResult.content,
        createdAt: now,
        updatedAt: now,
      );

      await _repository.addNote(note);
      state = state.copyWith(isLoading: false);
    } catch (e, st) {
      debugPrint('createNoteFromAsrInput error: $e');
      debugPrintStack(stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể xử lý ghi âm thành ghi chú: $e',
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
    _notesSub?.cancel();
    super.dispose();
  }
}

final notesViewModelProvider =
    StateNotifierProvider<NotesViewModel, NotesState>((ref) {
  final repository = ref.watch(notesRepositoryProvider);
  final noteAiService = ref.watch(noteAiServiceProvider);
  return NotesViewModel(ref, repository, noteAiService);
});
