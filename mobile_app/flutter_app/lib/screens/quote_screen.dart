import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/app_theme.dart';
import 'settings_screen.dart'; // Imported so the toggle can safely route to settings

class QuoteScreen extends StatefulWidget {
  final String emotion;
  final List<String> quotes;

  const QuoteScreen({
    super.key, 
    required this.emotion, 
    this.quotes = const [], 
  });

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  bool isButtonPressed = false; // Tracks the touch state for our animation

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    // Existing Fallback Logic Preserved
    final displayQuotes = widget.quotes.isEmpty 
        ? ["Your motivational quote will appear here. You are stronger than you think."] 
        : widget.quotes;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          child: Column(
            children: [
              // Top Right Toggle (Matches 4_2.png visually)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 24.0, top: 10.0),
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
                          icon: const Icon(Icons.toggle_on, color: Colors.white, size: 28),
                          onPressed: () {
                            // Safely route to Settings
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SettingsScreen()),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              
              // Typography matching 4_2.png
              Text(
                "A quote for your", 
                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w300, fontSize: 20)
              ),
              Text(
                "${widget.emotion[0].toUpperCase()}${widget.emotion.substring(1)} moment", 
                style: textTheme.headlineLarge?.copyWith(fontSize: 34),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 30),

              // Glassmorphic Carousel Cards
              Expanded(
                child: PageView.builder(
                  itemCount: displayQuotes.length,
                  physics: const BouncingScrollPhysics(),
                  controller: PageController(viewportFraction: 0.85),
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                displayQuotes[index],
                                textAlign: TextAlign.center,
                                style: textTheme.bodyLarge?.copyWith(
                                    fontSize: 22, 
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Animated Bottom Circular Camera Button (Scan Again)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: GestureDetector(
                  // Animation triggers
                  onTapDown: (_) => setState(() => isButtonPressed = true),
                  onTapUp: (_) {
                    setState(() => isButtonPressed = false);
                    // Preserved original routing logic
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  onTapCancel: () => setState(() => isButtonPressed = false),
                  
                  // Animated Container handles the smooth scale effect
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
                    transform: Matrix4.diagonal3Values(
                      isButtonPressed ? 0.9 : 1.0, 
                      isButtonPressed ? 0.9 : 1.0, 
                      1.0
                    ),
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.25),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
                        ),
                      ),
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