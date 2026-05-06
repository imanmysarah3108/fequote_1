import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/app_theme.dart';
import 'reflect_screen.dart';
import 'settings_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: AppTheme.backgroundGradient,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    
                    // UI Match: "Quote" Title
                    Text(
                      "Quote",
                      textAlign: TextAlign.center,
                      style: textTheme.headlineLarge?.copyWith(
                        fontSize: 52, // Scaled up to match the reference
                      ),
                    ),
                    
                    // UI Match: "My Mood" Subtitle
                    Text(
                      "My Mood",
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w300, // Light weight for elegant contrast
                      ),
                    ),
                    
                    const Spacer(flex: 1),

                    // YOUR CUSTOM BIG LOGO
                    // Ensure the path matches exactly what is in pubspec.yaml
                    Image.asset(
                      'assets/images/app_logo.png',
                      width: 280, // Large size to match the reference
                      height: 280,
                      fit: BoxFit.contain,
                    ),
                    
                    const Spacer(flex: 2),

                    // Glassmorphic 'Get Started' Button
                    Container(
                      margin: const EdgeInsets.only(bottom: 40),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 60),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.4), 
                              width: 1.5,
                            ),
                          ),
                        ),
                        onPressed: () {
                          // Preserved routing logic
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReflectScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Get Started",
                          style: textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Top Right Settings Button (Glass Pill)
          Positioned(
            top: 50, // Standard safe area padding
            right: 24,
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
                  child: IconButton(
                    // UI Match: Using toggle_on to match your design visually 
                    // while keeping it functioning as the settings button
                    icon: const Icon(Icons.toggle_on, color: Colors.white, size: 28),
                    onPressed: () {
                      // Preserved routing logic
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}