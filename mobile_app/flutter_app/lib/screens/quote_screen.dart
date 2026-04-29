import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/app_theme.dart';

class QuoteScreen extends StatelessWidget {
  final String emotion;
  final List<String> quotes; // Upgraded to receive the API quotes

  const QuoteScreen({
    super.key, 
    required this.emotion, 
    this.quotes = const [], // Default empty list to prevent navigation bar errors
  });

  @override
  Widget build(BuildContext context) {
    // Fallback if accessed via bottom nav without scanning
    final displayQuotes = quotes.isEmpty 
        ? ["Your motivational quote will appear here. You are stronger than you think."] 
        : quotes;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF7F3),
              Color(0xFFFFE5D9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              
              Text(
                "A quote for your",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                "$emotion moment",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primary,
                ),
              ),

              const SizedBox(height: 30),

              // Dynamic Size Glass Cards Slider
              Expanded(
                child: PageView.builder(
                  itemCount: displayQuotes.length,
                  physics: const BouncingScrollPhysics(),
                  controller: PageController(viewportFraction: 0.88),
                  itemBuilder: (context, index) {
                    return Center(
                      child: IntrinsicHeight(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Colors.white.withValues(alpha: 0.6),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withValues(alpha: 0.1),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.format_quote_rounded,
                                    color: AppTheme.secondary,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "“${displayQuotes[index]}”",
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontSize: 20,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              // Outline Pill Button to Scan Again
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary, width: 2),
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: Text(
                    "Scan Again",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}