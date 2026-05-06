import 'package:flutter/material.dart';
import 'constants/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/notification_service.dart';
import 'services/local_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.requestPermission();
  await LocalNotificationService.init();
  await NotificationService.init();
  runApp(const FaceQuoteApp());
}

class FaceQuoteApp extends StatelessWidget {
  const FaceQuoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FaceQuote',
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
    );
  }
}