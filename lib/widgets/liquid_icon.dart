import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/liquid_colors.dart';

class LiquidIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const LiquidIcon({
    super.key,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: LiquidColors.glass,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, size: 28),
          ),
        ),
      ),
    );
  }
}