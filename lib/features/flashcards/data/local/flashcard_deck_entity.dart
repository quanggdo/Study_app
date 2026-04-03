import 'package:isar/isar.dart';

part 'flashcard_deck_entity.g.dart';

@collection
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
  @Index(unique: true, replace: true)
  late String id;

  @Index()
  late String uId;

  late String title;
  String? description;

  late List<String> tags;

  late int cardCount;

  DateTime? lastStudiedAt;

  late DateTime createdAt;
  late DateTime updatedAt;

  @Index()
  late bool isDeleted;
}

