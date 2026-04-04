// Conditional export to prevent Web from compiling Isar generated code.
//
// On Web, Isar codegen (`*.g.dart`) contains 64-bit integer literals that break
// JS compilation. The app doesn't use Isar on Web anyway.
export 'flashcard_isar_local_stub.dart'
    if (dart.library.io) 'flashcard_isar_local_io.dart';

