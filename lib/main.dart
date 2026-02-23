import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Firebase Messaging and Local Notifications
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // ADD THIS
import '../services/notification_service.dart';

// pages
import 'login_page.dart';

// your real app pages
import 'screens/home/home_page.dart';
import 'screens/alert/alerts_page.dart';
import 'screens/help/help_page.dart';
import 'screens/profile/profile_page.dart';
import 'screens/monitor/monitor_page.dart';
import 'screens/checklist/checklist_page.dart';
import 'screens/communitypost/community_posts_page.dart';
import 'screens/shelter/shelter_page.dart';


// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message: ${message.messageId}');
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Background handler (mobile only — not supported on web)
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}

// ================= AUTH WRAPPER =================
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const MainApp();
        }

        return const LoginPage();
      },
    );
  }
}

// ================= MAIN APP =================
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/alerts': (context) => const AlertsPage(),
        '/help': (context) => const HelpPage(),
        '/profile': (context) => const ProfilePage(),
        '/monitor': (context) => const MonitorPage(),
        '/checklist': (context) => const ChecklistPage(),
        '/community': (context) => const CommunityPostsPage(),
        '/shelters': (context) => const ShelterPage(),
      },
    );
  }
}



