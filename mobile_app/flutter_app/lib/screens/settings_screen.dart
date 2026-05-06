import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui';
import '../services/local_notification_service.dart';
import '../constants/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isNotificationOn = true;
  TimeOfDay selectedTime = const TimeOfDay(hour: 20, minute: 0);
  String? deviceId;
  bool isLoading = true;

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
    final doc = await FirebaseFirestore.instance.collection("notification_preferences").doc(deviceId).get();
    if (doc.exists) {
      setState(() {
        isNotificationOn = doc['daily_reminder'] ?? true;
        String time = doc['reminder_time'] ?? "20:00";
        final parts = time.split(":");
        selectedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      });
    }
    setState(() => isLoading = false);
  }

  Future<void> _saveSettings() async {
    final timeString = "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";
    await FirebaseFirestore.instance.collection("notification_preferences").doc(deviceId).set({
      "device_id": deviceId,
      "daily_reminder": isNotificationOn,
      "reminder_time": timeString,
    });

    if (isNotificationOn) {
      await LocalNotificationService.scheduleDailyNotification(hour: selectedTime.hour, minute: selectedTime.minute);
    } else {
      await LocalNotificationService.cancelAll();
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Settings saved", style: TextStyle(color: Colors.white)), backgroundColor: AppTheme.primaryPurple),
      );
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        _saveSettings(); // Auto save on time change for better UX
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeString = "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')} ${selectedTime.period == DayPeriod.am ? 'AM' : 'PM'}";
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.backgroundGradient,
        child: isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    // Glass Back Button
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Header with Bell
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Settings', style: textTheme.headlineLarge),
                            const SizedBox(height: 8),
                            Text('Stay in tune with your mood.', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w300)),
                          ],
                        ),
                        // Replace with Image.asset if you have the 3D bell image
                        const Icon(Icons.notifications_active, color: Colors.white70, size: 60),
                      ],
                    ),
                    const SizedBox(height: 50),

                    // Daily Reminder Glass Card
                    _buildGlassCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Daily Mood Reminder', style: textTheme.bodyLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 6),
                                Text('Get a gentle check-in everyday.', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300)),
                              ],
                            ),
                          ),
                          Switch(
                            value: isNotificationOn,
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppTheme.primaryPurple,
                            inactiveThumbColor: Colors.white70,
                            inactiveTrackColor: Colors.white30,
                            onChanged: (value) {
                              setState(() => isNotificationOn = value);
                              _saveSettings();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Reminder Time Glass Card
                    _buildGlassCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Reminder Time', style: textTheme.bodyLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 6),
                                Text('Choose when you want the\nnotification to appear.', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _pickTime,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryPurple.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time, color: Colors.white, size: 14),
                                  const SizedBox(width: 6),
                                  Text(timeString, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right, color: Colors.white, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }
}