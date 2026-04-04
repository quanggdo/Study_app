import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/firebase_functions_service.dart';

final firebaseFunctionsServiceProvider = Provider<FirebaseFunctionsService>((ref) {
  return FirebaseFunctionsService();
});

