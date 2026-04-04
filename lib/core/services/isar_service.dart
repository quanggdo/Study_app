import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'isar_schemas_stub.dart'
    if (dart.library.io) 'isar_schemas_io.dart';

/// Central place to open/keep the Isar instance.
///
/// Hiện tại chỉ đăng ký schemas cho Flashcards. Khi mở rộng, thêm schema vào đây.
class IsarService {
  IsarService._(this.isar);

  final Isar isar;

  static Future<IsarService> open() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Isar is not supported on Web in this project configuration.',
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      isarSchemas,
      directory: dir.path,
    );

    return IsarService._(isar);
  }
}

final isarServiceProvider = Provider<IsarService>((ref) {
  throw UnimplementedError(
    'isarServiceProvider must be overridden in main() after opening Isar',
  );
});
