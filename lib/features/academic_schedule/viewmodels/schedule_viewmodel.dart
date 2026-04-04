import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/providers/user_provider.dart';
import '../models/class_session_model.dart';
import '../repositories/schedule_repository.dart';
import '../services/schedule_ai_service.dart';

class ScheduleState {
  final bool isSubmitting;
  final bool isImporting;
  final String? errorMessage;
  final String? latestExtractedText;

  const ScheduleState({
    this.isSubmitting = false,
    this.isImporting = false,
    this.errorMessage,
    this.latestExtractedText,
  });

  ScheduleState copyWith({
    bool? isSubmitting,
    bool? isImporting,
    String? errorMessage,
    String? latestExtractedText,
  }) {
    return ScheduleState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isImporting: isImporting ?? this.isImporting,
      errorMessage: errorMessage,
      latestExtractedText: latestExtractedText ?? this.latestExtractedText,
    );
  }
}

class ScheduleNotifier extends StateNotifier<ScheduleState> {
  final ScheduleRepository _repository;
  final ScheduleAiService _aiService;

  ScheduleNotifier(this._repository, this._aiService)
      : super(const ScheduleState());

  Future<bool> addManualSession({
    required String uid,
    required String subjectName,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    String room = '',
    List<ClassSessionModel> existingSessions = const <ClassSessionModel>[],
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final String normalizedSubject = subjectName.trim();
      final String normalizedRoom = room.trim();
      if (normalizedSubject.isEmpty) {
        throw Exception('Vui lòng nhập tên môn học.');
      }
      if (!_isValidTime(startTime) || !_isValidTime(endTime)) {
        throw Exception('Thời gian phải có định dạng HH:mm.');
      }

      if (_hasTimeConflict(
        existingSessions,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
      )) {
        throw Exception(
            'Khung giờ này bị trùng hoặc chồng lấn với thời khóa biểu hiện có.');
      }

      await _repository.createManualSession(
        uid: uid,
        subjectName: normalizedSubject,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
        room: normalizedRoom,
      );

      state = state.copyWith(isSubmitting: false, errorMessage: null);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<int> importFromImage({
    required String uid,
    required ImageSource source,
    bool replaceExisting = false,
    List<ClassSessionModel> existingSessions = const <ClassSessionModel>[],
  }) async {
    state = state.copyWith(isImporting: true, errorMessage: null);

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2000,
      );

      if (file == null) {
        state = state.copyWith(isImporting: false, errorMessage: null);
        return 0;
      }

      final ScheduleAiResult result =
          await _aiService.extractScheduleFromImage(file);

      final List<ClassSessionModel> validSessions = <ClassSessionModel>[];
      for (final ClassSessionModel session in result.sessions) {
        if (!_hasTimeConflict(
          <ClassSessionModel>[
            ...replaceExisting ? <ClassSessionModel>[] : existingSessions,
            ...validSessions,
          ],
          dayOfWeek: session.dayOfWeek,
          startTime: session.startTime,
          endTime: session.endTime,
        )) {
          validSessions.add(session);
        }
      }

      if (replaceExisting) {
        await _repository.replaceAllSessionsFromImage(
          uid: uid,
          sessions: validSessions,
        );
      } else {
        await _repository.createSessionsFromImage(
          uid: uid,
          sessions: validSessions,
        );
      }

      state = state.copyWith(
        isImporting: false,
        errorMessage: null,
        latestExtractedText: result.rawText,
      );

      if (validSessions.length != result.sessions.length) {
        state = state.copyWith(
          errorMessage:
              'Một số buổi học bị bỏ qua vì trùng hoặc chồng lấn thời gian.',
        );
      }

      return validSessions.length;
    } catch (e) {
      state = state.copyWith(
        isImporting: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return 0;
    }
  }

  Future<bool> updateSession({
    required String sessionId,
    required String subjectName,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    String room = '',
    List<ClassSessionModel> existingSessions = const <ClassSessionModel>[],
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final String normalizedSubject = subjectName.trim();
      final String normalizedRoom = room.trim();

      if (normalizedSubject.isEmpty) {
        throw Exception('Vui lòng nhập tên môn học.');
      }
      if (!_isValidTime(startTime) || !_isValidTime(endTime)) {
        throw Exception('Thời gian phải có định dạng HH:mm.');
      }

      final List<ClassSessionModel> sessionsWithoutCurrent = existingSessions
          .where((ClassSessionModel s) => s.id != sessionId)
          .toList();

      if (_hasTimeConflict(
        sessionsWithoutCurrent,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
      )) {
        throw Exception(
          'Khung giờ chỉnh sửa bị trùng hoặc chồng lấn với buổi học khác.',
        );
      }

      await _repository.updateSession(
        sessionId: sessionId,
        subjectName: normalizedSubject,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
        room: normalizedRoom,
      );

      state = state.copyWith(isSubmitting: false, errorMessage: null);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await _repository.deleteSession(sessionId);
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  bool _isValidTime(String value) {
    return RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(value);
  }

  bool _hasTimeConflict(
    List<ClassSessionModel> sessions, {
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) {
    final int newStart = _timeToMinutes(startTime);
    final int newEnd = _timeToMinutes(endTime);

    for (final ClassSessionModel session in sessions) {
      if (session.dayOfWeek != dayOfWeek) {
        continue;
      }

      final int existingStart = _timeToMinutes(session.startTime);
      final int existingEnd = _timeToMinutes(session.endTime);

      final bool overlap = newStart < existingEnd && newEnd > existingStart;
      if (overlap) {
        return true;
      }
    }

    return false;
  }

  int _timeToMinutes(String value) {
    final List<String> parts = value.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}

final scheduleNotifierProvider =
    StateNotifierProvider<ScheduleNotifier, ScheduleState>((ref) {
  final ScheduleRepository repository = ref.watch(scheduleRepositoryProvider);
  final ScheduleAiService aiService = ref.watch(scheduleAiServiceProvider);
  return ScheduleNotifier(repository, aiService);
});

final userScheduleStreamProvider =
    StreamProvider.autoDispose<List<ClassSessionModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream<List<ClassSessionModel>>.value(<ClassSessionModel>[]);
  }

  final ScheduleRepository repository = ref.watch(scheduleRepositoryProvider);
  return repository.watchSchedules(user.uid);
});
