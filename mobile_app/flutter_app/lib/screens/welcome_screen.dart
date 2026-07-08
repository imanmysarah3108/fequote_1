import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/app_theme.dart';
import 'reflect_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXl),
            child: Column(
              children: [
                const Spacer(flex: 3),
                Text(
                  'Quote',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineLarge?.copyWith(fontSize: 48),
                ),
                const SizedBox(height: 4),
                Text(
                  'My Mood',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(flex: 2),
                Image.asset(
                  'assets/images/app_logo.png',
                  width: 240,
                  height: 240,
                  fit: BoxFit.contain,
                ),
                const Spacer(flex: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      width: double.infinity,
                      height: AppTheme.buttonHeight,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.45),
                          width: 1,
                        ),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ReflectScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                          child: Center(
                            child: Text(
                              'Get Started',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceXl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
