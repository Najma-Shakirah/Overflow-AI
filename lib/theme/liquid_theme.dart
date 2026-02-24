import 'package:flutter/material.dart';
import 'liquid_colors.dart';

class LiquidTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: 'SFPro', // optional
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.white),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: LiquidColors.primary,
      ),
    );
  }
}