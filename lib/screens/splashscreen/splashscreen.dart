import 'package:flutter/material.dart';
import 'dart:async';
import '../../config/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Scale animation
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Start animation
    _controller.forward();

    // Navigate to home after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Liquid gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF00C6FF),
                  Color(0xFF0072FF),
                  Color(0xFF667EEA),
                ],
              ),
            ),
          ),

          // Animated floating bubbles
          _AnimatedBubble(
            duration: 4,
            size: 200,
            top: 100,
            right: -50,
          ),
          _AnimatedBubble(
            duration: 5,
            size: 250,
            bottom: 150,
            left: -80,
          ),
          _AnimatedBubble(
            duration: 6,
            size: 150,
            top: 400,
            left: 50,
          ),

          // Main content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App icon with liquid effect
                    Container(
                      width: 120,
                      height: 120,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              Color(0xFFE0F7FF),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.water_drop,
                          size: 50,
                          color: Color(0xFF0072FF),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // App name
                    const Text(
                      'Overflow AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Tagline
                    Text(
                      'Flood Monitoring System',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                    
                    const SizedBox(height: 50),
                    
                    // Loading indicator
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Animated bubble widget
class _AnimatedBubble extends StatefulWidget {
  final int duration;
  final double size;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const _AnimatedBubble({
    required this.duration,
    required this.size,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  @override
  State<_AnimatedBubble> createState() => _AnimatedBubbleState();
}

class _AnimatedBubbleState extends State<_AnimatedBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: widget.duration),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: widget.top,
          bottom: widget.bottom,
          left: widget.left,
          right: widget.right,
          child: Transform.translate(
            offset: Offset(0, _controller.value * 20 - 10),
            child: Container(
              width: widget.size,
              height: widget.size,
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
        );
      },
    );
  }
}