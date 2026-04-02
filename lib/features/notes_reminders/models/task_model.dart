import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskPriority { high, medium, low }

class TaskModel {
  final String id;
  final String uId;
  final String title;
  final DateTime deadline;
  final bool isCompleted;
  final int reminderId;
  final TaskPriority priority;
  final DateTime createdAt;

  const TaskModel({
    required this.id,
    required this.uId,
    required this.title,
    required this.deadline,
    this.isCompleted = false,
    required this.reminderId,
    this.priority = TaskPriority.medium,
    required this.createdAt,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    TaskPriority parsePriority(String? p) {
      switch (p) {
        case 'high':
          return TaskPriority.high;
        case 'low':
          return TaskPriority.low;
        case 'medium':
        default:
          return TaskPriority.medium;
      }
    }

    return TaskModel(
      id: doc.id,
      uId: data['u_id'] ?? '',
      title: data['title'] ?? '',
      deadline: (data['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCompleted: data['is_completed'] ?? false,
      reminderId: data['reminder_id'] ?? 0,
      priority: parsePriority(data['priority'] as String?),
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'u_id': uId,
      'title': title,
      'deadline': Timestamp.fromDate(deadline),
      'is_completed': isCompleted,
      'reminder_id': reminderId,
      'priority': priority.name,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  TaskModel copyWith({
    String? id,
    String? uId,
    String? title,
    DateTime? deadline,
    bool? isCompleted,
    int? reminderId,
    TaskPriority? priority,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      uId: uId ?? this.uId,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderId: reminderId ?? this.reminderId,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
