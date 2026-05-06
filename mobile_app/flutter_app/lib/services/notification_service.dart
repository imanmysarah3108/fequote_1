import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static Future<void> init() async {
    // Request permission
    await _fcm.requestPermission();

    // Get token
    String? token = await _fcm.getToken();
    print("📲 FCM Token: $token");

    // Get device ID
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString("device_id");

    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString("device_id", deviceId);
    }

    // Save to Firestore
    await FirebaseFirestore.instance
        .collection("notification_preferences")
        .doc(deviceId)
        .set({
      "device_id": deviceId,
      "fcm_token": token,
      "daily_reminder": true,
      "reminder_time": "08:00"
    });
  }
}