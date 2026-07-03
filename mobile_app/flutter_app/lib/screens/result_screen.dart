import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../constants/app_theme.dart';
import '../providers/quote_provider.dart';
import '../providers/navigation_provider.dart';
import 'quote_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quote = context.watch<QuoteProvider>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXl),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Text(
                  'You seem a bit',
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceLg),
                _EmotionBubble(emotion: quote.emotion.toLowerCase()),
                const SizedBox(height: AppTheme.spaceLg),
                Text(
                  "We've analyzed your expression. Let's take a deep breath and find a moment of peace through words.",
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                    height: 1.45,
                  ),
                ),
                const Spacer(flex: 2),
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            context.read<NavigationProvider>().setIndex(1);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const QuoteScreen()),
                            );
                          },
                          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                          child: Center(
                            child: Text(
                              'Find My Quote',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    'Scan Again',
                    style: textTheme.bodyMedium?.copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                      fontWeight: FontWeight.w300,
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

class _EmotionBubble extends StatelessWidget {
  final String emotion;

  const _EmotionBubble({required this.emotion});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.35),
            AppTheme.primaryPurple.withValues(alpha: 0.55),
            AppTheme.primaryPurple.withValues(alpha: 0.75),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withValues(alpha: 0.35),
            blurRadius: 40,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(-6, -6),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          emotion,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
