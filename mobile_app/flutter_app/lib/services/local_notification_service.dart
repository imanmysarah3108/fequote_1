import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

/// Handles the daily mood check-in reminder — a LOCAL scheduled notification
/// (flutter_local_notifications + AlarmManager). No FCM / server involved.
class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// The one channel every notification in this app uses, so what the user
  /// sees under System Settings > Notifications matches what we schedule.
  static const String channelId = 'daily_reminder_channel';
  static const String channelName = 'Daily Mood Reminder';
  static const String channelDescription =
      'Your daily check-in reminder to log how you feel.';

  /// Device timezone. Malaysia has no DST and is fixed at UTC+8. If this app is
  /// ever shipped outside Malaysia, swap this for the `flutter_timezone` package
  /// to detect the zone at runtime.
  static const String _localTimeZone = 'Asia/Kuala_Lumpur';

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    channelId,
    channelName,
    channelDescription: channelDescription,
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  static const NotificationDetails _details =
      NotificationDetails(android: _androidDetails);

  // Stable id so scheduling is idempotent (re-scheduling replaces, not stacks).
  static const int dailyReminderId = 1001;

  static Future<void> init() async {
    // Load the timezone database, then pin `tz.local` to the device zone.
    // Without setLocalLocation, tz.local is UTC and every reminder fires 8h off.
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(_localTimeZone));
    } catch (e) {
      debugPrint('Timezone set failed: $e');
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onTap,
      onDidReceiveBackgroundNotificationResponse: _onTapBackground,
    );

    // Create the channel up-front so it exists (and is inspectable in System
    // Settings) before the first notification, rather than lazily on first fire.
    await _androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max,
      ),
    );
  }

  static AndroidFlutterLocalNotificationsPlugin? get _androidPlugin =>
      _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  static void _onTap(NotificationResponse response) {
    // Reminder tap: app opens to its normal home. Nothing extra needed for now.
    debugPrint('Notification tapped: ${response.payload}');
  }

  @pragma('vm:entry-point')
  static void _onTapBackground(NotificationResponse response) {
    debugPrint('Background notification tapped: ${response.payload}');
  }

  /// Android 13+ runtime notification permission. Returns granted?/null.
  /// Idempotent — no dialog is shown once already granted.
  static Future<bool?> requestNotificationPermission() async {
    return _androidPlugin?.requestNotificationsPermission();
  }

  /// Daily repeating reminder at [hour]:[minute] local time.
  static Future<void> scheduleDailyNotification({
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      id: dailyReminderId,
      title: 'Daily Check-In',
      body: 'How are you feeling today? Take a moment to reflect. 🌸',
      scheduledDate: _nextInstance(hour, minute),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancel(int id) async {
    await _notifications.cancel(id: id);
  }

  static tz.TZDateTime _nextInstance(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
