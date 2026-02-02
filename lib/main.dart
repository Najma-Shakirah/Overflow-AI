import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';
import 'alerts_page.dart';
import 'help_page.dart';
import 'profile_page.dart';
import 'monitor_page.dart';

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
      },
    );
  }
}