import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/app_theme.dart';
import 'quote_screen.dart';

class ResultScreen extends StatelessWidget {
  final String emotion;
  final List<String> quotes;

  const ResultScreen({
    super.key,
    required this.emotion,
    required this.quotes,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top Right Toggle (Visual Match)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: ClipRRect(
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
                          child: const Icon(Icons.toggle_on, color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const Spacer(),
                Text("You seem a bit", style: textTheme.bodyLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.w300)),
                const SizedBox(height: 40),

                // Giant Glass Circle
                ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      height: 260,
                      width: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.1),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          emotion.toLowerCase(),
                          style: textTheme.headlineLarge?.copyWith(fontSize: 40),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 50),
                Text(
                  "We've analyzed your expression.\nLet's take a deep breath and find a\nmoment of peace through words.",
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w300, fontSize: 16),
                ),
                const Spacer(),

                // Glass Pill Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuoteScreen(emotion: emotion, quotes: quotes),
                      ),
                    );
                  },
                  child: Text(
                    "Find My Quote",
                    style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 20),

                // Scan Again Text Button
                GestureDetector(
                  onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
                  child: Text(
                    "Scan Again",
                    style: textTheme.bodyLarge?.copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}