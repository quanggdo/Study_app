import 'package:isar/isar.dart';

import 'isar_schemas_flashcard_stub.dart'
    if (dart.library.io) 'isar_schemas_flashcard_io.dart';

/// Schemas dùng cho IO platforms (Android/iOS/Windows/macOS/Linux).
const List<CollectionSchema<dynamic>> isarSchemas = <CollectionSchema<dynamic>>[
  ...flashcardIsarSchemas,
];
