import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String uId;
  final String subjectId;
  final String content;
  final String? audioUrl;
  final bool isFromAsr;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteModel({
    required this.id,
    required this.uId,
    required this.subjectId,
    required this.content,
    this.audioUrl,
    this.isFromAsr = false,
    this.isSynced = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return NoteModel(
      id: doc.id,
      uId: data['u_id'] ?? '',
      subjectId: data['subject_id'] ?? '',
      content: data['content'] ?? '',
      audioUrl: data['audio_url'],
      isFromAsr: data['is_from_asr'] ?? false,
      isSynced: data['is_synced'] ?? true,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'u_id': uId,
      'subject_id': subjectId,
      'content': content,
      'audio_url': audioUrl,
      'is_from_asr': isFromAsr,
      'is_synced': isSynced,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  NoteModel copyWith({
    String? id,
    String? uId,
    String? subjectId,
    String? content,
    String? audioUrl,
    bool? isFromAsr,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      uId: uId ?? this.uId,
      subjectId: subjectId ?? this.subjectId,
      content: content ?? this.content,
      audioUrl: audioUrl ?? this.audioUrl,
      isFromAsr: isFromAsr ?? this.isFromAsr,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
