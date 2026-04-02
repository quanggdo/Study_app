import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
<<<<<<< HEAD
import 'core/services/firebase_service.dart';
import 'core/services/notification_service.dart';
=======
import 'core/services/firebase_auth_service.dart';
>>>>>>> master
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

<<<<<<< HEAD
  // Khởi tạo nền tảng Firebase
  await FirebaseService.initialize();
  await NotificationService.initialize();
=======
  // Khởi tạo nền tảng Firebase (thông qua FirebaseAuthService)
  await FirebaseAuthService.initialize();
>>>>>>> master

  runApp(
    const ProviderScope(
      child: StudentAcademicAssistantApp(),
    ),
  );
}

class StudentAcademicAssistantApp extends ConsumerWidget {
  const StudentAcademicAssistantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Student Academic Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
