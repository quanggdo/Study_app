import 'package:firebase_core/firebase_core.dart';
import '../utils/firebase_options.dart';

class FirebaseService {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("Firebase initialized successfully");
    } catch (e) {
      print("Firebase init error: $e");
    }
  }
}