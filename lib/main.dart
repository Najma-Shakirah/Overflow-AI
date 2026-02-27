import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/ai_service.dart';

import 'screens/authentication/auth_viewmodel.dart';
import 'screens/weather/weather_viewmodel.dart';
import 'screens/news/news_viewmodel.dart';

// pages
import 'screens/authentication/login_page.dart';
import 'screens/authentication/register_page.dart';
import 'screens/home/home_page.dart';
import 'screens/alert/alerts_page.dart';
import 'screens/help/help_page.dart';
import 'screens/profile/profile_page.dart';
import 'screens/profile/notification_settings_page.dart';
import 'screens/profile/location_preferences_page.dart';
import 'screens/profile/privacy_security_page.dart';
import 'screens/profile/about_page.dart';
import 'screens/monitor/monitor_page.dart';
import 'screens/checklist/checklist_page.dart';
import 'screens/communitypost/community_posts_page.dart';
import 'screens/shelter/shelter_page.dart';
import 'screens/ai/photos_analyser_page.dart';
import 'screens/ai/evacuation_plan_page.dart';
import 'screens/news/news_page.dart';
import 'screens/splashscreen/splashscreen.dart';
import 'screens/games/game_view.dart';
import 'screens/monitor/monitor_repository.dart';
import 'screens/games/gamedashboard.dart';
import 'screens/games/floodgame.dart';
import 'screens/games/floodrisinggame/floodrisinggamepage.dart';
import 'screens/report/report_page.dart';

// Global navigator key — used to navigate from notification taps
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Store for alert data passed in via notification tap
class PendingAlertStore {
  static Map<String, dynamic>? pending;
}

// Background FCM message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();  
  await MonitorRepository.openBoxes(); 

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Init notifications in background — don't block UI
  final notificationService = NotificationService();
  notificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => WeatherViewModel(),
        ),
        ChangeNotifierProvider(create: (_) => NewsViewModel()),
        Provider(
          create: (_) => AIService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.varelaRoundTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF0072FF), // your main blue
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      navigatorKey: navigatorKey,
      initialRoute: '/splashscreen',
      routes: {
        '/splashscreen': (context) => const SplashScreen(),
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/alerts': (context) => const AlertsPage(),
        '/help': (context) => const HelpPage(),
        '/profile': (context) => const ProfilePage(),
        '/notification-settings': (context) => const NotificationSettingsPage(),
        '/location-preferences': (context) => const LocationPreferencesPage(),
        '/privacy-security': (context) => const PrivacySecurityPage(),
        '/about': (context) => const AboutPage(),
        '/monitor': (context) => const MonitorPage(),
        '/checklist': (context) => const ChecklistPage(),
        '/community': (context) => const CommunityPostsPage(),
        '/shelters': (context) => const ShelterPage(),
        '/analyse-photo': (context) => const FloodPhotoAnalyserPage(),
        '/evacuation': (context) => const EvacuationPlanPage(),
        '/news': (context) => const NewsPage(),
        '/game': (context) => const SnakeGamePage(),
        '/gamedashboard': (context) => const GameDashboard(),
        '/floodgame': (context) => const FloodSurvivalGamePage(),
        '/floodrisinggame': (context) => const FloodRisingGamePage(),
        '/report': (context) => const ReportPage(),
      },
    );
  }
}

// ================= AUTH WRAPPER =================
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthViewModel>().state;

    switch (authState) {
      case AuthState.initial:
      case AuthState.loading:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case AuthState.authenticated:
        return const MainApp();
      case AuthState.unauthenticated:
      case AuthState.error:
        return const LoginPage();
    }
  }
}

// ================= MAIN APP =================
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyHomePage();
  }
}
