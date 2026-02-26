import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
        ChangeNotifierProvider(
          create: (_) => NewsViewModel()
        ),
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
        '/monitor': (context) => const MonitorPage(),
        '/checklist': (context) => const ChecklistPage(),
        '/community': (context) => const CommunityPostsPage(),
        '/shelters': (context) => const ShelterPage(),
        '/analyse-photo': (context) => const FloodPhotoAnalyserPage(),
        '/evacuation': (context) => const EvacuationPlanPage(),
        '/news': (context) => const NewsPage(), 
        '/game': (context) => const SnakeGamePage(), 
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
