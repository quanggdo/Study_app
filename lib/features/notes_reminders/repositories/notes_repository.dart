import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/firestore_constants.dart';
import '../../../core/services/notification_service.dart';
import '../models/note_model.dart';
import '../models/task_model.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository(FirebaseFirestore.instance);
});

class NotesRepository {
  final FirebaseFirestore _firestore;

  NotesRepository(this._firestore);

  Stream<List<TaskModel>> watchTasks(String uid) {
    return _firestore
        .collection(FirestoreConstants.tasks)
        .where('u_id', isEqualTo: uid)
        .orderBy('deadline')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(TaskModel.fromFirestore).toList();
    });
  }

  Stream<List<NoteModel>> watchNotes(String uid) {
    return _firestore
        .collection(FirestoreConstants.notes)
        .where('u_id', isEqualTo: uid)
        .orderBy('updated_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(NoteModel.fromFirestore).toList();
    });
  }

  Future<void> addTask(TaskModel task) async {
    await _firestore
        .collection(FirestoreConstants.tasks)
        .add(task.toFirestore());

    await NotificationService.scheduleReminder(
      id: task.reminderId,
      title: task.type == StudyTaskType.schedule
          ? 'Nhắc lịch học: ${task.subject}'
          : 'Deadline: ${task.subject}',
      body: task.title,
      scheduledAt: task.deadline,
      alarmStyle: task.type == StudyTaskType.deadline,
    );
  }

  Future<void> toggleTaskComplete(TaskModel task) async {
    await _firestore.collection(FirestoreConstants.tasks).doc(task.id).update({
      'is_completed': !task.isCompleted,
    });
  }

  Future<void> deleteTask(TaskModel task) async {
    await _firestore.collection(FirestoreConstants.tasks).doc(task.id).delete();
    await NotificationService.cancelReminder(task.reminderId);
  }

  Future<void> addNote(NoteModel note) async {
    await _firestore
        .collection(FirestoreConstants.notes)
        .add(note.toFirestore());
  }

  Future<void> deleteNote(String noteId) async {
    await _firestore.collection(FirestoreConstants.notes).doc(noteId).delete();
  }
}
