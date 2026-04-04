import 'package:isar/isar.dart';

part 'flashcard_card_entity.g.dart';

@collection
@pragma('vm:entry-point')
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

  @Index(unique: true, replace: true, name: 'card_id_idx')
  late String id;

  @Index(name: 'card_deck_id_idx')
  late String deckId;

  @Index(name: 'card_u_id_idx')
  late String uId;

  late String front;
  late String back;
  String? hint;

  late DateTime createdAt;
  late DateTime updatedAt;

  @Index(name: 'card_is_deleted_idx')
  late bool isDeleted;
}

// Nếu build web: không dùng Isar, nên tránh việc reference tới schema.
// (File .g.dart vẫn tồn tại cho mobile/desktop builds.)
