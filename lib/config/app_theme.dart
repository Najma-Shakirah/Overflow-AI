import 'package:flutter/material.dart';
import 'dart:ui';

class AppColors {
  // Liquid gradient colors (like iOS)
  static const Color liquidBlue1 = Color(0xFF00C6FF);
  static const Color liquidBlue2 = Color(0xFF0072FF);
  static const Color liquidPurple1 = Color(0xFF667EEA);
  static const Color liquidPurple2 = Color(0xFF764BA2);
  static const Color liquidGreen1 = Color(0xFF56CCF2);
  static const Color liquidGreen2 = Color(0xFF2F80ED);
  
  // Glass/Frosted effect colors
  static const Color glassWhite = Color(0xFFFFFFFF);
  static const Color glassBackground = Color(0x40FFFFFF);
  
  // Severity colors with liquid style
  static const Color critical = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9500);
  static const Color info = Color(0xFF007AFF);
  static const Color success = Color(0xFF34C759);
  
  // Text colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // Liquid gradients
  static const LinearGradient liquidGradient1 = LinearGradient(
    colors: [liquidBlue1, liquidBlue2],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient liquidGradient2 = LinearGradient(
    colors: [liquidPurple1, liquidPurple2],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient liquidGradient3 = LinearGradient(
    colors: [liquidGreen1, liquidGreen2],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get liquidTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF2F2F7),
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.liquidBlue2,
        brightness: Brightness.light,
      ),
      
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}