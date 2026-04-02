import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/firestore_constants.dart';
import '../models/class_session_model.dart';

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository(FirebaseFirestore.instance);
});

class ScheduleRepository {
  final FirebaseFirestore _firestore;

  ScheduleRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreConstants.schedules);

  Stream<List<ClassSessionModel>> watchSchedules(String uid) {
    return _collection.where('u_id', isEqualTo: uid).snapshots().map(
      (QuerySnapshot<Map<String, dynamic>> snapshot) {
        final List<ClassSessionModel> sessions = snapshot.docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
          return ClassSessionModel.fromFirestore(doc);
        }).toList();

        sessions.sort((ClassSessionModel a, ClassSessionModel b) {
          final int dayCompare = a.dayOfWeek.compareTo(b.dayOfWeek);
          if (dayCompare != 0) {
            return dayCompare;
          }
          return a.startTime.compareTo(b.startTime);
        });

        return sessions;
      },
    );
  }

  Future<void> createManualSession({
    required String uid,
    required String subjectName,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required String room,
  }) async {
    await _collection.add(<String, dynamic>{
      'u_id': uid,
      'subject_name': subjectName,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'room': room,
      'is_from_ocr': false,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createSessionsFromImage({
    required String uid,
    required List<ClassSessionModel> sessions,
  }) async {
    if (sessions.isEmpty) {
      return;
    }

    final WriteBatch batch = _firestore.batch();
    for (final ClassSessionModel session in sessions) {
      final DocumentReference<Map<String, dynamic>> docRef = _collection.doc();
      batch.set(docRef, <String, dynamic>{
        'u_id': uid,
        'subject_name': session.subjectName,
        'day_of_week': session.dayOfWeek,
        'start_time': session.startTime,
        'end_time': session.endTime,
        'room': session.room,
        'is_from_ocr': true,
        'created_at': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> deleteSession(String sessionId) async {
    await _collection.doc(sessionId).delete();
  }
}
