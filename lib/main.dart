import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'core/routing/app_router.dart';
import 'core/services/firebase_auth_service.dart';
import 'core/services/isar_service.dart';
import 'core/theme/app_theme.dart';

import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  await FirebaseAuthService.initialize();

  final notificationService = NotificationService();
  await notificationService.initialize();

  final overrides = <Override>[
    notificationServiceProvider.overrideWithValue(notificationService),
  ];

  if (!kIsWeb) {
    final isarService = await IsarService.open();
    overrides.add(isarServiceProvider.overrideWithValue(isarService));
  }

  runApp(
    ProviderScope(
      overrides: overrides,
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
