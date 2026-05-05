import 'package:flutter/material.dart';
import 'constants/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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