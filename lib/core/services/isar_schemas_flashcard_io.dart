import 'package:isar/isar.dart';

import '../../features/flashcards/data/local/flashcard_card_entity.dart';
import '../../features/flashcards/data/local/flashcard_deck_entity.dart';
import '../../features/flashcards/data/local/review_state_entity.dart';

const List<CollectionSchema<dynamic>> flashcardIsarSchemas =
    <CollectionSchema<dynamic>>[
  FlashcardDeckEntitySchema,
  FlashcardCardEntitySchema,
  ReviewStateEntitySchema,
];

