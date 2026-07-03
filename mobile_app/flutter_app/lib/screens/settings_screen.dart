import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../constants/app_theme.dart';
import '../providers/settings_provider.dart';
import '../app_routes.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../screens/reflect_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsProvider>().init();
  }

  void _goToDashboard() {
    Navigator.pushNamed(context, AppRoutes.moodDashboard);
  }

  void _goToCamera() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ReflectScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final timeString =
        '${settings.selectedTime.hour.toString().padLeft(2, '0')}:${settings.selectedTime.minute.toString().padLeft(2, '0')} ${settings.selectedTime.period == DayPeriod.am ? 'AM' : 'PM'}';
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.backgroundGradient,
        child: settings.isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppTheme.spaceMd),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Settings',
                                        style: textTheme.headlineLarge,
                                      ),
                                      const SizedBox(height: AppTheme.spaceXs),
                                      Text(
                                        'Stay in tune with your mood.',
                                        style: textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white.withValues(alpha: 0.3),
                                        AppTheme.primaryPurple.withValues(alpha: 0.4),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryPurple.withValues(alpha: 0.25),
                                        blurRadius: 16,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.notifications_active_outlined,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spaceLg),
                            _buildGlassCard(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Daily Mood Reminder',
                                          style: textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Get a gentle check-in everyday.',
                                          style: textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: settings.isNotificationOn,
                                    activeThumbColor: Colors.white,
                                    activeTrackColor: AppTheme.primaryPurple,
                                    inactiveThumbColor: Colors.white70,
                                    inactiveTrackColor: Colors.white30,
                                    onChanged: (value) {
                                      context.read<SettingsProvider>().toggleNotification(value);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Settings saved',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: AppTheme.primaryPurple,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppTheme.spaceMd),
                            _buildGlassCard(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Reminder Time',
                                          style: textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Choose when you want the\nnotification to appear.',
                                          style: textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      await context.read<SettingsProvider>().pickTime(context);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Settings saved',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                            backgroundColor: AppTheme.primaryPurple,
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppTheme.spaceSm,
                                        vertical: AppTheme.spaceXs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryPurple.withValues(alpha: 0.4),
                                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.45),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            timeString,
                                            style: textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: AppTheme.labelSize,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          const Icon(
                                            Icons.chevron_right,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AppBottomNavBar(
                      activeTab: BottomNavTab.settings,
                      onDashboard: _goToDashboard,
                      onCamera: _goToCamera,
                      onSettings: () {},
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
