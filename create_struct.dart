import 'dart:io';

void main() {
  final baseDir = Directory('lib');
  if (!baseDir.existsSync()) {
    baseDir.createSync();
  }

  final coreDirs = [
    'core/constants',
    'core/utils',
    'core/routing',
    'core/providers',
    'core/services',
  ];

  final featureDirs = [
    'auth',
    'academic_schedule',
    'notes_reminders',
    'flashcards',
    'quizzes',
    'pomodoro',
    'dashboard',
  ];

  final featureSubDirs = [
    'models',
    'repositories',
    'viewmodels',
    'views',
  ];

  // Create core directories
  for (var dir in coreDirs) {
    Directory('lib/$dir').createSync(recursive: true);
  }

  // Create feature directories
  for (var feature in featureDirs) {
    for (var sub in featureSubDirs) {
      Directory('lib/features/$feature/$sub').createSync(recursive: true);
    }
  }

  // Create core placeholder files
  final coreFiles = [
    'core/providers/user_provider.dart',
    'core/services/ocr_service.dart',
    'core/services/asr_service.dart',
    'core/services/notification_service.dart',
    'core/services/firebase_service.dart',
  ];

  for (var file in coreFiles) {
    File('lib/$file').writeAsStringSync('// Placeholder for $file');
  }

  // Create feature placeholder files
  final featureFiles = {
    'auth': ['models/user_model.dart', 'viewmodels/auth_viewmodel.dart', 'repositories/auth_repository.dart', 'views/login_screen.dart'],
    'academic_schedule': ['models/subject_model.dart', 'models/class_session_model.dart', 'viewmodels/schedule_viewmodel.dart', 'repositories/schedule_repository.dart', 'views/timetable_screen.dart'],
    'notes_reminders': ['models/note_model.dart', 'models/task_model.dart', 'viewmodels/notes_viewmodel.dart', 'repositories/notes_repository.dart', 'views/tasks_screen.dart'],
    'flashcards': ['models/deck_model.dart', 'models/flashcard_model.dart', 'viewmodels/flashcard_viewmodel.dart', 'repositories/flashcard_repository.dart', 'views/flashcard_screen.dart'],
    'quizzes': ['models/quiz_model.dart', 'models/question_model.dart', 'models/quiz_result_model.dart', 'viewmodels/quiz_viewmodel.dart', 'repositories/quiz_repository.dart', 'views/quiz_screen.dart'],
    'pomodoro': ['models/pomodoro_session_model.dart', 'viewmodels/timer_viewmodel.dart', 'repositories/pomodoro_repository.dart', 'views/timer_screen.dart'],
    'dashboard': ['models/study_stats_model.dart', 'viewmodels/stats_viewmodel.dart', 'repositories/dashboard_repository.dart', 'views/progress_charts_widget.dart'],
  };

  featureFiles.forEach((feature, files) {
    for (var file in files) {
      File('lib/features/$feature/$file').writeAsStringSync('// Placeholder for $feature/$file');
    }
  });

  print('Directory structure created successfully.');
}
