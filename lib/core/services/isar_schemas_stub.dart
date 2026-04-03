import 'package:isar/isar.dart';

/// Stub schemas for platforms that don't support Isar/opening local DB.
///
/// Web compile sẽ fail nếu kéo theo Isar generated `*.g.dart` (do 64-bit literals).
/// Vì vậy trên Web chúng ta export list rỗng và KHÔNG BAO GIỜ gọi open().
const List<CollectionSchema<dynamic>> isarSchemas = <CollectionSchema<dynamic>>[];

