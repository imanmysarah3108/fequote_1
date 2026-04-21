import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import 'reflect_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFE5D9),
              Color(0xFFFFF7F3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Reflect Your\nMood",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge,
            ),

            const SizedBox(height: 20),

            Text(
              "Scan your face. Get inspired by quotes that match your emotion.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 60),

            Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(110),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFC1A1),
                    Color(0xFFFF8A65),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 25,
                    spreadRadius: 5,
                  )
                ],
              ),
            ),

            const SizedBox(height: 60),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReflectScreen(),
                  ),
                );
              },
              child: const Text(
                "GET STARTED",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}