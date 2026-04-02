import 'package:cloud_firestore/cloud_firestore.dart';

enum StudyTaskType { schedule, deadline }

class TaskModel {
  final String id;
  final String uId;
  final String title;
  final String subject;
  final String? description;
  final DateTime deadline;
  final bool isCompleted;
  final int reminderId;
  final StudyTaskType type;
  final DateTime createdAt;

  const TaskModel({
    required this.id,
    required this.uId,
    required this.title,
    required this.subject,
    this.description,
    required this.deadline,
    required this.isCompleted,
    required this.reminderId,
    required this.type,
    required this.createdAt,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TaskModel(
      id: doc.id,
      uId: data['u_id'] ?? '',
      title: data['title'] ?? '',
      subject: data['subject'] ?? '',
      description: data['description'],
      deadline: (data['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCompleted: data['is_completed'] ?? false,
      reminderId: data['reminder_id'] ?? 0,
      type: (data['type'] ?? 'deadline') == 'schedule'
          ? StudyTaskType.schedule
          : StudyTaskType.deadline,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'u_id': uId,
      'title': title,
      'subject': subject,
      'description': description,
      'deadline': Timestamp.fromDate(deadline),
      'is_completed': isCompleted,
      'reminder_id': reminderId,
      'type': type == StudyTaskType.schedule ? 'schedule' : 'deadline',
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  TaskModel copyWith({
    String? id,
    String? uId,
    String? title,
    String? subject,
    String? description,
    DateTime? deadline,
    bool? isCompleted,
    int? reminderId,
    StudyTaskType? type,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      uId: uId ?? this.uId,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderId: reminderId ?? this.reminderId,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
