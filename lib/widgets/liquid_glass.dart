import 'package:flutter/material.dart';

class LiquidBackground extends StatelessWidget {
  final List<Color> gradientColors;
  final Widget child;

  const LiquidBackground({
    super.key,
    required this.child,
    this.gradientColors = const [
      Color(0xFF00C6FF),
      Color(0xFF0072FF),
      Color(0xFF667EEA),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
        ),
        
        // Floating bubble 1
        Positioned(
          top: 100,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
        
        // Floating bubble 2
        Positioned(
          bottom: 200,
          left: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
        
        // Floating bubble 3
        Positioned(
          top: 300,
          left: 50,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
        
        // Content
        child,
      ],
    );
  }
}