import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../services/local_notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isNotificationOn = true;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0);
  String? _deviceId;
  bool _isLoading = true;

  bool get isNotificationOn => _isNotificationOn;
  TimeOfDay get selectedTime => _selectedTime;
  String? get deviceId => _deviceId;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString('device_id');

    if (_deviceId == null) {
      _deviceId = const Uuid().v4();
      await prefs.setString('device_id', _deviceId!);
    }

    // Load from local storage first — instant and offline-safe. This is what
    // keeps the screen from hanging on a spinner when Firestore is slow/offline.
    _isNotificationOn = prefs.getBool('reminder_enabled') ?? _isNotificationOn;
    final localHour = prefs.getInt('reminder_hour');
    final localMinute = prefs.getInt('reminder_minute');
    if (localHour != null && localMinute != null) {
      _selectedTime = TimeOfDay(hour: localHour, minute: localMinute);
    }
    _isLoading = false;
    notifyListeners();

    // Then reconcile with Firestore in the background — never blocks the UI,
    // and a failure/timeout can't leave the screen stuck.
    _syncFromFirestore();
  }

  Future<void> _syncFromFirestore() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('notification_preferences')
          .doc(_deviceId)
          .get()
          .timeout(const Duration(seconds: 8));

      if (!doc.exists) return;
      final data = doc.data();
      if (data == null) return;

      _isNotificationOn = data['daily_reminder'] ?? _isNotificationOn;
      final time = data['reminder_time'];
      if (time is String && time.contains(':')) {
        final parts = time.split(':');
        _selectedTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
      notifyListeners();
    } catch (_) {
      // Offline or slow — the local values already loaded are good enough.
    }
  }

  Future<void> saveSettings() async {
    final timeString =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    // Local mirror first — survives offline and is what startup re-arm reads.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_enabled', _isNotificationOn);
    await prefs.setInt('reminder_hour', _selectedTime.hour);
    await prefs.setInt('reminder_minute', _selectedTime.minute);

    await FirebaseFirestore.instance
        .collection('notification_preferences')
        .doc(_deviceId)
        .set({
      'device_id': _deviceId,
      'daily_reminder': _isNotificationOn,
      'reminder_time': timeString,
    }, SetOptions(merge: true));

    if (_isNotificationOn) {
      // Ask for notification permission (Android 13+) before scheduling.
      // Idempotent: no dialog shown once already granted.
      await LocalNotificationService.requestNotificationPermission();
      await LocalNotificationService.scheduleDailyNotification(
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
      );
    } else {
      await LocalNotificationService.cancel(
        LocalNotificationService.dailyReminderId,
      );
    }
  }

  /// Re-arm the daily reminder on app startup from the local mirror, so it
  /// survives restarts, reinstalls-with-same-prefs, and ColorOS alarm clears.
  /// Safe to call every launch — zonedSchedule replaces the same id.
  static Future<void> ensureScheduledOnStartup() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('reminder_enabled') ?? false;
    if (!enabled) return;
    final hour = prefs.getInt('reminder_hour') ?? 20;
    final minute = prefs.getInt('reminder_minute') ?? 0;
    await LocalNotificationService.scheduleDailyNotification(
      hour: hour,
      minute: minute,
    );
  }

  void toggleNotification(bool value) {
    _isNotificationOn = value;
    notifyListeners();
    saveSettings();
  }

  Future<void> pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      _selectedTime = picked;
      notifyListeners();
      await saveSettings();
    }
  }
}
