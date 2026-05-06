import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../services/local_notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isNotificationOn = true;
  TimeOfDay selectedTime = const TimeOfDay(hour: 20, minute: 0);

  String? deviceId;

  @override
  void initState() {
    super.initState();
    _initDevice();
  }

  Future<void> _initDevice() async {
    final prefs = await SharedPreferences.getInstance();
    deviceId = prefs.getString("device_id");

    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString("device_id", deviceId!);
    }

    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    final doc = await FirebaseFirestore.instance
        .collection("notification_preferences")
        .doc(deviceId)
        .get();

    if (doc.exists) {
      setState(() {
        isNotificationOn = doc['daily_reminder'] ?? true;

        String time = doc['reminder_time'] ?? "20:00";
        final parts = time.split(":");

        selectedTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      });
    }
  }

  Future<void> _saveSettings() async {
    final timeString =
        "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";

    await FirebaseFirestore.instance
        .collection("notification_preferences")
        .doc(deviceId)
        .set({
      "device_id": deviceId,
      "daily_reminder": isNotificationOn,
      "reminder_time": timeString,
    });

      // ✅ CONTROL NOTIFICATION HERE
  if (isNotificationOn) {
    await LocalNotificationService.scheduleDailyNotification(
      hour: selectedTime.hour,
      minute: selectedTime.minute,
    );
  } else {
    await LocalNotificationService.cancelAll();
  }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Settings saved")),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notification Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text("Daily Reminder"),
              value: isNotificationOn,
              onChanged: (value) {
                setState(() {
                  isNotificationOn = value;
                });
              },
            ),

            const SizedBox(height: 20),

            ListTile(
              title: const Text("Reminder Time"),
              subtitle: Text(
                  "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}"),
              trailing: const Icon(Icons.access_time),
              onTap: _pickTime,
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text("Save Settings"),
            ),
          ],
        ),
      ),
    );
  }
}