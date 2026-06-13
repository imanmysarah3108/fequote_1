import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/settings_provider.dart';
import '../viewmodels/mood_dashboard_viewmodel.dart';
import '../widgets/glass_container.dart';
import '../widgets/mood_bubble.dart';
import '../screens/reflect_screen.dart';
import '../screens/settings_screen.dart';

class MoodDashboardScreen extends StatefulWidget {
  const MoodDashboardScreen({super.key});

  @override
  State<MoodDashboardScreen> createState() => _MoodDashboardScreenState();
}

class _MoodDashboardScreenState extends State<MoodDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDashboard());
  }

  Future<void> _loadDashboard() async {
    final settings = context.read<SettingsProvider>();
    if (settings.deviceId == null) {
      await settings.init();
    }
    final deviceId = context.read<SettingsProvider>().deviceId;
    if (deviceId != null) {
      await context.read<MoodDashboardViewModel>().loadDashboard(deviceId);
    }
  }

  String _formatWeekRange(DateTime start, DateTime end) {
    final formatter = DateFormat('d MMMM yyyy');
    return '${formatter.format(start)} – ${formatter.format(end)}';
  }

  String _summaryEmoji(String title) {
    switch (title) {
      case 'Positive':
        return '😊';
      case 'Needs Support':
        return '😢';
      case 'Emotionally Strained':
        return '😠';
      default:
        return '😌';
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MoodDashboardViewModel>();
    final textTheme = Theme.of(context).textTheme;
    final dashboard = vm.dashboard;

    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          child: vm.isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        color: AppTheme.primaryPurple,
                        onRefresh: _loadDashboard,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              Text(
                                'My Mood Dashboard',
                                style: textTheme.headlineLarge?.copyWith(fontSize: 32),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'This week',
                                style: textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                _formatWeekRange(dashboard.weekStart, dashboard.weekEnd),
                                style: textTheme.bodyMedium?.copyWith(fontSize: 13),
                              ),
                              const SizedBox(height: 28),
                              if (vm.error != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    vm.error!,
                                    style: textTheme.bodyMedium?.copyWith(color: Colors.red.shade200),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              Row(
                                children: [
                                  const Icon(Icons.auto_awesome, color: Colors.white70, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'AI Weekly Summary',
                                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              GlassContainer(
                                borderRadius: 24,
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.white.withValues(alpha: 0.35),
                                            AppTheme.primaryPurple.withValues(alpha: 0.4),
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _summaryEmoji(dashboard.summary.title),
                                          style: const TextStyle(fontSize: 42),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dashboard.summary.title,
                                            style: textTheme.headlineMedium?.copyWith(fontSize: 26),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            dashboard.summary.description,
                                            style: textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w300,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),
                              Text(
                                'Weekly Mood Distribution',
                                style: textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 16),
                              MoodBubbleField(distribution: dashboard.distribution),
                              const SizedBox(height: 20),
                              GlassContainer(
                                borderRadius: 24,
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mood Statistics',
                                      style: textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _statRow(
                                      textTheme,
                                      'Total Mood Scans',
                                      '${dashboard.statistics.totalScans}',
                                    ),
                                    _statRow(
                                      textTheme,
                                      'Most Frequent Emotion',
                                      dashboard.statistics.mostFrequentEmotion,
                                    ),
                                    _statRow(
                                      textTheme,
                                      'Average Confidence',
                                      '${dashboard.statistics.averageConfidence}%',
                                    ),
                                    _statRow(
                                      textTheme,
                                      'Days Tracked',
                                      '${dashboard.statistics.daysTracked}',
                                    ),
                                  ],
                                ),
                              ),
                              if (vm.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Text(
                                    'No mood scans this week yet. Tap the camera to start tracking.',
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300),
                                  ),
                                ),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _DashboardBottomBar(
                      onDashboard: () {},
                      onCamera: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ReflectScreen()),
                        );
                      },
                      onSettings: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        );
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _statRow(TextTheme textTheme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodyMedium),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _DashboardBottomBar extends StatelessWidget {
  final VoidCallback onDashboard;
  final VoidCallback onCamera;
  final VoidCallback onSettings;

  const _DashboardBottomBar({
    required this.onDashboard,
    required this.onCamera,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 32, right: 32, top: 12, bottom: 24),
      decoration: BoxDecoration(
        color: AppTheme.primaryPeach.withValues(alpha: 0.35),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            isActive: true,
            onTap: onDashboard,
          ),
          GestureDetector(
            onTap: onCamera,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryPurple.withValues(alpha: 0.8),
                    Colors.white.withValues(alpha: 0.5),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
            ),
          ),
          _NavItem(
            icon: Icons.settings_rounded,
            label: 'Settings',
            isActive: false,
            onTap: onSettings,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.primaryPurple : Colors.white.withValues(alpha: 0.6);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
