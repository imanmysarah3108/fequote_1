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
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    final doc = await FirebaseFirestore.instance
        .collection('notification_preferences')
        .doc(_deviceId)
        .get();

    if (doc.exists) {
      _isNotificationOn = doc['daily_reminder'] ?? true;
      final time = doc['reminder_time'] ?? '20:00';
      final parts = time.split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveSettings() async {
    final timeString =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    await FirebaseFirestore.instance
        .collection('notification_preferences')
        .doc(_deviceId)
        .set({
      'device_id': _deviceId,
      'daily_reminder': _isNotificationOn,
      'reminder_time': timeString,
    });

    if (_isNotificationOn) {
      await LocalNotificationService.scheduleDailyNotification(
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
      );
    } else {
      await LocalNotificationService.cancelAll();
    }
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
