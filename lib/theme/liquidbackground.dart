import 'dart:ui';
import 'package:flutter/material.dart';

class LiquidBackground extends StatelessWidget {
  final Widget child;
  final String imagePath;

  const LiquidBackground({
    super.key,
    required this.child,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
        ),
        child,
      ],
    );
  }
}