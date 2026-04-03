import 'package:cloud_firestore/cloud_firestore.dart';

class ClassSessionModel {
  final String id;
  final String uid;
  final String subjectName;
  final int dayOfWeek; // 2..8 (2=Mon, 8=Sun)
  final String startTime; // HH:mm
  final String endTime; // HH:mm
  final String room;
  final bool isFromOcr;
  final DateTime createdAt;

  const ClassSessionModel({
    required this.id,
    required this.uid,
    required this.subjectName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.isFromOcr,
    required this.createdAt,
  });

  factory ClassSessionModel.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ClassSessionModel(
      id: doc.id,
      uid: data['u_id'] as String? ?? '',
      subjectName: data['subject_name'] as String? ?? '',
      dayOfWeek: data['day_of_week'] as int? ?? 2,
      startTime: data['start_time'] as String? ?? '00:00',
      endTime: data['end_time'] as String? ?? '00:00',
      room: data['room'] as String? ?? '',
      isFromOcr: data['is_from_ocr'] as bool? ?? false,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'u_id': uid,
      'subject_name': subjectName,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'room': room,
      'is_from_ocr': isFromOcr,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
