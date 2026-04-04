import 'class_session_model.dart';

class SubjectModel {
  final String name;
  final List<ClassSessionModel> sessions;

  const SubjectModel({
    required this.name,
    required this.sessions,
  });

  static List<SubjectModel> fromSessions(List<ClassSessionModel> allSessions) {
    final Map<String, List<ClassSessionModel>> grouped =
        <String, List<ClassSessionModel>>{};

    for (final ClassSessionModel session in allSessions) {
      grouped.putIfAbsent(session.subjectName, () => <ClassSessionModel>[]);
      grouped[session.subjectName]!.add(session);
    }

    return grouped.entries
        .map(
          (MapEntry<String, List<ClassSessionModel>> e) => SubjectModel(
            name: e.key,
            sessions: e.value,
          ),
        )
        .toList();
  }
}
