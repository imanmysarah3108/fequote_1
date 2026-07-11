import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/local_notification_service.dart';
import 'providers/navigation_provider.dart';
import 'providers/quote_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/reflect_provider.dart';
import 'viewmodels/mood_dashboard_viewmodel.dart';
import 'viewmodels/quote_rewrite_viewmodel.dart';
import 'views/mood_dashboard_screen.dart';
import 'views/ai_rewrite_screen.dart';
import 'app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocalNotificationService.init();
  // Re-arm the daily reminder from saved prefs (survives restarts/ColorOS clears).
  await SettingsProvider.ensureScheduledOnStartup();
  runApp(const FaceQuoteApp());
}

class FaceQuoteApp extends StatelessWidget {
  const FaceQuoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => QuoteProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ReflectProvider()),
        ChangeNotifierProvider(create: (_) => MoodDashboardViewModel()),
        ChangeNotifierProvider(create: (_) => QuoteRewriteViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FaceQuote',
        theme: AppTheme.lightTheme,
        home: const WelcomeScreen(),
        routes: {
          AppRoutes.moodDashboard: (_) => const MoodDashboardScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.aiRewrite) {
            final quote = settings.arguments as String? ?? '';
            return MaterialPageRoute(
              builder: (_) => AIRewriteScreen(selectedQuote: quote),
            );
          }
          return null;
        },
      ),
    );
  }
}
