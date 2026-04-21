import 'package:flutter/material.dart';
import 'constants/app_theme.dart';
import 'screens/welcome_screen.dart';

void main() {
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