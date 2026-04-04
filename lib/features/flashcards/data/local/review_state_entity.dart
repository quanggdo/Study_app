import 'package:isar/isar.dart';

part 'review_state_entity.g.dart';

@collection
@pragma('vm:entry-point')
class ReviewStateEntity {
  ReviewStateEntity({
    required this.cardId,
    required this.deckId,
    required this.uId,
    required this.dueAt,
    this.reps = 0,
    this.lapses = 0,
    this.intervalDays = 0,
    this.easeFactor = 2.5,
    this.lastReviewedAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true, name: 'card_id_idx')
  late String cardId;

  @Index(name: 'deck_id_idx')
  late String deckId;

  @Index(name: 'u_id_idx')
  late String uId;

  late DateTime dueAt;
  late int reps;
  late int lapses;
  late int intervalDays;
  late double easeFactor;
  DateTime? lastReviewedAt;
  late DateTime updatedAt;

  @Index(name: 'is_deleted_idx')
  late bool isDeleted;
}
