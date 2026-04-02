import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/firestore_constants.dart';
import '../../../core/services/notification_service.dart';
import '../models/note_model.dart';
import '../models/task_model.dart';

final notesRemindersRepositoryProvider = Provider<NotesRemindersRepository>((ref) {
  return NotesRemindersRepository(
    firestore: FirebaseFirestore.instance,
    notificationService: ref.watch(notificationServiceProvider),
  );
});

class NotesRemindersRepository {
  final FirebaseFirestore _firestore;
  final NotificationService _notificationService;
  final Set<String> _migrateAttemptedDocIds = <String>{};

  NotesRemindersRepository({
    required FirebaseFirestore firestore,
    required NotificationService notificationService,
  })  : _firestore = firestore,
        _notificationService = notificationService;

  Stream<List<TaskModel>> watchTasks(String uid) {
    return _firestore
        .collection(FirestoreConstants.tasks)
        .where('u_id', isEqualTo: uid)
        .orderBy('deadline')
        .snapshots()
        .map((snapshot) {
      final tasks = snapshot.docs.map(TaskModel.fromFirestore).toList();

      for (final task in tasks) {
        if (_shouldMigrateReminderId(task)) {
          _migrateAttemptedDocIds.add(task.id);
          unawaited(_performBackgroundMigration(task.id));
        }
      }

      return tasks;
    });
  }

  Stream<List<NoteModel>> watchNotes(String uid) {
    return _firestore
        .collection(FirestoreConstants.notes)
        .where('u_id', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final notes = snapshot.docs.map(NoteModel.fromFirestore).toList();
      notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return notes;
    });
  }

  Future<void> addTask(TaskModel task) async {
    final taskRef = _firestore.collection(FirestoreConstants.tasks).doc();
    final finalTask = task.copyWith(
      id: taskRef.id,
      reminderId: _safeReminderIdFromDocId(taskRef.id),
    );

    await taskRef.set(finalTask.toFirestore());

    if (_shouldScheduleReminder(finalTask)) {
      await _safeScheduleTaskReminder(finalTask);
    }
  }

  Future<bool> toggleTaskComplete(TaskModel task) async {
    if (task.id.isEmpty) {
      throw StateError('Task không hợp lệ: thiếu id.');
    }

    final taskRef = _firestore.collection(FirestoreConstants.tasks).doc(task.id);
    var newStatus = !task.isCompleted;

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(taskRef);
        if (!snapshot.exists) {
          throw StateError('Task không tồn tại để cập nhật.');
        }

        final data = snapshot.data();
        if (data is! Map<String, dynamic>) {
          throw StateError('Dữ liệu task không hợp lệ.');
        }

        final currentCompleted = data['is_completed'];
        final currentStatus = currentCompleted is bool ? currentCompleted : false;
        newStatus = !currentStatus;

        transaction.update(taskRef, {
          'is_completed': newStatus,
        });
      });
    } catch (e, st) {
      debugPrint(
        '[NotesRemindersRepository] Transaction toggle lỗi, thử fallback update. '
        'taskId=${task.id}: $e',
      );
      debugPrintStack(stackTrace: st);

      newStatus = !task.isCompleted;
      await taskRef.update({
        'is_completed': newStatus,
      });
    }

    if (newStatus) {
      await _safeCancelReminder(task.reminderId);
    } else {
      final updatedTask = task.copyWith(isCompleted: newStatus);
      if (_shouldScheduleReminder(updatedTask)) {
        await _safeScheduleTaskReminder(updatedTask);
      }
    }

    return newStatus;
  }

  Future<void> deleteTask(TaskModel task) async {
    await _firestore.collection(FirestoreConstants.tasks).doc(task.id).delete();
    await _safeCancelReminder(task.reminderId);
  }

  Future<void> updateTask({
    required TaskModel oldTask,
    required TaskModel newTask,
  }) async {
    await _firestore
        .collection(FirestoreConstants.tasks)
        .doc(newTask.id)
        .update(newTask.toFirestore());

    if (!_needsReschedule(oldTask, newTask)) {
      return;
    }

    await _safeCancelReminder(oldTask.reminderId);
    if (newTask.reminderId != oldTask.reminderId) {
      await _safeCancelReminder(newTask.reminderId);
    }

    if (_shouldScheduleReminder(newTask)) {
      await _safeScheduleTaskReminder(newTask);
    }
  }

  Future<void> addNote(NoteModel note) async {
    await _firestore.collection(FirestoreConstants.notes).add(note.toFirestore());
  }

  Future<void> deleteNote(String noteId) async {
    await _firestore.collection(FirestoreConstants.notes).doc(noteId).delete();
  }

  Future<void> updateNote(NoteModel note) async {
    await _firestore
        .collection(FirestoreConstants.notes)
        .doc(note.id)
        .update(note.toFirestore());
  }

  bool _shouldMigrateReminderId(TaskModel task) {
    if (task.id.isEmpty) return false;
    if (task.reminderId > 0) return false;
    return !_migrateAttemptedDocIds.contains(task.id);
  }

  Future<void> _performBackgroundMigration(String taskId) async {
    final taskRef = _firestore.collection(FirestoreConstants.tasks).doc(taskId);
    final migratedReminderId = _safeReminderIdFromDocId(taskId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(taskRef);
        if (!snapshot.exists) return;

        final data = snapshot.data();
        if (data is! Map<String, dynamic>) return;

        final currentReminderId = data['reminder_id'];
        if (currentReminderId is num && currentReminderId > 0) {
          return;
        }

        transaction.update(taskRef, {'reminder_id': migratedReminderId});
      });
    } catch (_) {
      // Silent background migration to avoid blocking task stream.
    }
  }

  int _safeReminderIdFromDocId(String docId) {
    var reminderId = docId.hashCode & 0x7fffffff;
    if (reminderId == 0) {
      reminderId = 1;
    }
    return reminderId;
  }

  bool _needsReschedule(TaskModel oldTask, TaskModel newTask) {
    return oldTask.title != newTask.title ||
        oldTask.deadline != newTask.deadline ||
        oldTask.priority != newTask.priority ||
        oldTask.isCompleted != newTask.isCompleted;
  }

  bool _shouldScheduleReminder(TaskModel task) {
    if (task.isCompleted) return false;
    return task.deadline.isAfter(DateTime.now());
  }

  Future<void> _safeScheduleTaskReminder(TaskModel task) async {
    try {
      await _notificationService.scheduleReminder(
        id: task.reminderId,
        title: task.priority == TaskPriority.high
            ? 'Nhắc khẩn cấp: ${task.title}'
            : 'Deadline: ${task.title}',
        body: 'Đến giờ rồi, tập trung làm việc bạn nhé!',
        scheduledAt: task.deadline,
        alarmStyle: task.priority == TaskPriority.high,
      );
    } catch (e, st) {
      debugPrint(
        '[NotesRemindersRepository] Failed to schedule notification '
        'for taskId=${task.id}, reminderId=${task.reminderId}: $e',
      );
      if (kIsWeb) {
        debugPrint(
          '[NotesRemindersRepository] Running on Web: local notifications '
          'are not supported by flutter_local_notifications.',
        );
      }
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> _safeCancelReminder(int reminderId) async {
    try {
      await _notificationService.cancelReminder(reminderId);
    } catch (e, st) {
      debugPrint(
        '[NotesRemindersRepository] Failed to cancel notification '
        'reminderId=$reminderId: $e',
      );
      if (kIsWeb) {
        debugPrint(
          '[NotesRemindersRepository] Running on Web: local notifications '
          'are not supported by flutter_local_notifications.',
        );
      }
      debugPrintStack(stackTrace: st);
    }
  }
}
