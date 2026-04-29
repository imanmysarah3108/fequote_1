import 'package:flutter/material.dart';
import 'dart:ui';
import 'home_screen.dart';
import 'reflect_screen.dart';
import 'quote_screen.dart';
import 'settings_screen.dart';
import '../constants/app_theme.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

final List<Widget> screens = const [
    HomeScreen(),
    ReflectScreen(),
    QuoteScreen(emotion: "Peaceful", quotes: []), // <--- To this
    SettingsScreen(),
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 30),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 75,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.darkText.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  navItem(Icons.home_rounded, 0),
                  navItem(Icons.camera_alt_rounded, 1),
                  navItem(Icons.format_quote_rounded, 2),
                  navItem(Icons.settings_rounded, 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget navItem(IconData icon, int index) {
    bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.secondary.withValues(alpha: 0.5) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppTheme.primary : AppTheme.darkText.withValues(alpha: 0.4),
          size: 28,
        ),
      ),
    );
  }
}