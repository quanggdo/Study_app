import 'package:isar/isar.dart';

part 'flashcard_card_entity.g.dart';

@collection
class FlashcardCardEntity {
  FlashcardCardEntity({
    required this.id,
    required this.deckId,
    required this.uId,
    required this.front,
    required this.back,
    this.hint,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  @Index()
  late String deckId;

  @Index()
  late String uId;

  late String front;
  late String back;
  String? hint;

  late DateTime createdAt;
  late DateTime updatedAt;

  @Index()
  late bool isDeleted;
}

