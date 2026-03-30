import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/firebase_service.dart';

import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo nền tảng Firebase
  await FirebaseService.initialize();

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
    return MaterialApp(
      title: 'Student Academic Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system, // Auto switch based on OS
      home: const Scaffold(
        body: Center(
          child: Text('Student Academic Assistant'),
        ),
      ),
    );
  }
}
