import 'package:cloud_functions/cloud_functions.dart';

/// Wrapper cho Firebase Cloud Functions.
///
/// - Centralize gọi Cloud Functions để dễ mock/test.
/// - Luồng Quiz dùng callable function `gradeQuiz`.
class FirebaseFunctionsService {
  FirebaseFunctionsService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  FirebaseFunctions get instance => _functions;
}

