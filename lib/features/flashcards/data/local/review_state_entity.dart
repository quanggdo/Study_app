import 'package:isar/isar.dart';

part 'review_state_entity.g.dart';

@collection
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

  @Index(unique: true, replace: true)
  late String cardId;

  @Index()
  late String deckId;

  @Index()
  late String uId;

  late DateTime dueAt;
  late int reps;
  late int lapses;
  late int intervalDays;
  late double easeFactor;
  DateTime? lastReviewedAt;
  late DateTime updatedAt;

  @Index()
  late bool isDeleted;
}

