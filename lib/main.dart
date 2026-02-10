import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home/home_page.dart';
import 'screens/alert/alerts_page.dart';
import 'screens/help/help_page.dart';
import 'screens/profile/profile_page.dart';
import 'screens/monitor/monitor_page.dart';
import 'screens/checklist/checklist_page.dart';
import 'screens/communitypost/community_posts_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        textTheme: GoogleFonts.varelaRoundTextTheme(),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/alerts': (context) => const AlertsPage(),
        '/help': (context) => const HelpPage(),
        '/profile': (context) => const ProfilePage(),
        '/monitor': (context) => const MonitorPage(),
        '/checklist': (context) => const ChecklistPage(),
        '/community': (context) => const CommunityPostsPage(),
      },
    );
  }
}
