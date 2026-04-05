import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_academic_assistant/core/constants/firestore_constants.dart';
import 'package:student_academic_assistant/features/notes/models/note_model.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository(firestore: FirebaseFirestore.instance);
});

class NotesRepository {
  final FirebaseFirestore _firestore;

  NotesRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

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
}
