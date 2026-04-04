import 'package:isar/isar.dart';

part 'flashcard_deck_entity.g.dart';

@collection
@pragma('vm:entry-point')
class FlashcardDeckEntity {
  FlashcardDeckEntity({
    required this.id,
    required this.uId,
    required this.title,
    this.description,
    this.tags = const <String>[],
    this.cardCount = 0,
    this.lastStudiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  /// Isar internal id.
  Id isarId = Isar.autoIncrement;

  /// Domain id (uuid/string) — unique per deck.
  @Index(unique: true, replace: true, name: 'deck_id_idx')
  late String id;

  @Index(name: 'deck_u_id_idx')
  late String uId;

  late String title;
  String? description;

  late List<String> tags;

  late int cardCount;

  DateTime? lastStudiedAt;

  late DateTime createdAt;
  late DateTime updatedAt;

  @Index(name: 'deck_is_deleted_idx')
  late bool isDeleted;
}
