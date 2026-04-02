import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    if (kIsWeb) {
      _initialized = true;
      return;
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    await _plugin.initialize(
      const InitializationSettings(
        android: android,
        iOS: ios,
      ),
    );

    final androidImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    bool alarmStyle = false,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Local notification is not supported on Web (scheduleReminder).',
      );
    }

    await _ensureInitialized();

    final scheduledTime = scheduledAt.toLocal();
    if (scheduledTime.isBefore(DateTime.now())) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        alarmStyle ? 'study_alarm_channel' : 'study_reminder_channel',
        alarmStyle ? 'Study Alarm' : 'Study Reminder',
        channelDescription: alarmStyle
            ? 'Thong bao kieu bao thuc cho deadline quan trong'
            : 'Nhac lich hoc va deadline',
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: alarmStyle,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
    } catch (e, st) {
      debugPrint('[NotificationService] scheduleReminder failed: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  Future<void> cancelReminder(int id) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Local notification is not supported on Web (cancelReminder).',
      );
    }

    await _ensureInitialized();

    try {
      await _plugin.cancel(id);
    } catch (e, st) {
      debugPrint('[NotificationService] cancelReminder failed: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await initialize();
  }
}
