import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/settings_provider.dart';
import '../viewmodels/mood_dashboard_viewmodel.dart';
import '../widgets/glass_container.dart';
import '../widgets/mood_bubble.dart';
import '../widgets/app_bottom_nav_bar.dart';
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
    final dayFormat = DateFormat('d MMMM');
    final yearFormat = DateFormat('yyyy');
    return '${dayFormat.format(start)} – ${dayFormat.format(end)} ${yearFormat.format(end)}';
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

  void _goToCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReflectScreen()),
    );
  }

  void _goToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
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
          bottom: false,
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
                          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
                          child: Column(
                            children: [
                              const SizedBox(height: AppTheme.spaceMd),
                              Text(
                                'My Mood Dashboard',
                                style: textTheme.headlineLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppTheme.spaceXs),
                              Text(
                                'This week',
                                style: textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontSize: AppTheme.sectionTitleSize,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatWeekRange(dashboard.weekStart, dashboard.weekEnd),
                                style: textTheme.bodyMedium,
                              ),
                              if (vm.error != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  vm.error!,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.red.shade200,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              const SizedBox(height: AppTheme.spaceLg),
                              Center(
                                child: Text(
                                  '✨ AI Weekly Summary',
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppTheme.spaceSm),
                              GlassContainer(
                                padding: const EdgeInsets.all(AppTheme.spaceMd),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.white.withValues(alpha: 0.35),
                                            AppTheme.primaryPurple.withValues(alpha: 0.45),
                                            AppTheme.primaryPeach.withValues(alpha: 0.35),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primaryPurple.withValues(alpha: 0.25),
                                            blurRadius: 16,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          _summaryEmoji(dashboard.summary.title),
                                          style: const TextStyle(fontSize: 36),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppTheme.spaceMd),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dashboard.summary.title,
                                            style: textTheme.headlineMedium,
                                          ),
                                          const SizedBox(height: AppTheme.spaceXs),
                                          Text(
                                            dashboard.summary.description,
                                            style: textTheme.bodyMedium,
                                            softWrap: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppTheme.spaceXl),
                              Text(
                                'Weekly Mood Distribution',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontSize: AppTheme.sectionTitleSize,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spaceMd),
                              MoodBubbleField(distribution: dashboard.distribution),
                              if (vm.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    'No mood scans this week yet. Tap the camera to start tracking.',
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodyMedium,
                                  ),
                                ),
                              const SizedBox(height: AppTheme.spaceLg),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AppBottomNavBar(
                      activeTab: BottomNavTab.dashboard,
                      onDashboard: () {},
                      onCamera: _goToCamera,
                      onSettings: _goToSettings,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
