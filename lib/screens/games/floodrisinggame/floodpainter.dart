// lib/screens/games/widgets/flood_painter.dart
import 'dart:math';
import 'package:flutter/material.dart';

class FloodPainter extends CustomPainter {
  final double floodLevel; // 0.0 to 1.0
  final double waveOffset; // animation offset for wave motion
  final bool isDanger;

  FloodPainter({
    required this.floodLevel,
    required this.waveOffset,
    required this.isDanger,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final floodTop = size.height * (1 - floodLevel);

    // ── Glow / danger aura above water ──────────────────────────────────
    if (isDanger) {
      final glowPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.red.withOpacity(0.35),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, floodTop - 80, size.width, 80));
      canvas.drawRect(
        Rect.fromLTWH(0, floodTop - 80, size.width, 80),
        glowPaint,
      );
    }

    // ── Wave 1 (front, brighter) ─────────────────────────────────────────
    final wavePath1 = _buildWavePath(
      size: size,
      floodTop: floodTop,
      waveOffset: waveOffset,
      waveHeight: 10,
      waveFrequency: 1.5,
    );

    final wave1Paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDanger
            ? [
                const Color(0xFFB71C1C).withOpacity(0.85),
                const Color(0xFF7F0000).withOpacity(0.95),
              ]
            : [
                const Color(0xFF1565C0).withOpacity(0.8),
                const Color(0xFF0D47A1).withOpacity(0.95),
              ],
      ).createShader(Rect.fromLTWH(0, floodTop, size.width, size.height));

    canvas.drawPath(wavePath1, wave1Paint);

    // ── Wave 2 (back, darker, offset) ───────────────────────────────────
    final wavePath2 = _buildWavePath(
      size: size,
      floodTop: floodTop + 6,
      waveOffset: waveOffset * 0.7 + 1.2,
      waveHeight: 8,
      waveFrequency: 2.0,
    );

    final wave2Paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDanger
            ? [
                const Color(0xFF7F0000).withOpacity(0.6),
                const Color(0xFF4A0000).withOpacity(0.8),
              ]
            : [
                const Color(0xFF0D47A1).withOpacity(0.5),
                const Color(0xFF0A2B6E).withOpacity(0.7),
              ],
      ).createShader(Rect.fromLTWH(0, floodTop, size.width, size.height));

    canvas.drawPath(wavePath2, wave2Paint);

    // ── Foam / bubbles on wave surface ───────────────────────────────────
    _drawFoam(canvas, size, floodTop, waveOffset, isDanger);

    // ── Depth gradient overlay ───────────────────────────────────────────
    final depthPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          (isDanger ? Colors.red : Colors.blue).withOpacity(0.3),
        ],
      ).createShader(Rect.fromLTWH(0, floodTop + 20, size.width, size.height));
    canvas.drawRect(
      Rect.fromLTWH(0, floodTop + 20, size.width, size.height - floodTop - 20),
      depthPaint,
    );
  }

  Path _buildWavePath({
    required Size size,
    required double floodTop,
    required double waveOffset,
    required double waveHeight,
    required double waveFrequency,
  }) {
    final path = Path();
    path.moveTo(0, floodTop);

    for (double x = 0; x <= size.width; x++) {
      final y = floodTop +
          sin((x / size.width * 2 * pi * waveFrequency) + waveOffset) *
              waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  void _drawFoam(Canvas canvas, Size size, double floodTop,
      double waveOffset, bool isDanger) {
    final foamPaint = Paint()
      ..color = Colors.white.withOpacity(isDanger ? 0.2 : 0.35)
      ..style = PaintingStyle.fill;

    final random = Random(42); // fixed seed for consistency
    for (int i = 0; i < 12; i++) {
      final x = (sin(waveOffset + i * 0.8) * 0.5 + 0.5) * size.width;
      final waveY = floodTop +
          sin((x / size.width * 2 * pi * 1.5) + waveOffset) * 10;
      final radius = random.nextDouble() * 3 + 1.5;
      canvas.drawCircle(Offset(x, waveY - radius), radius, foamPaint);
    }
  }

  @override
  bool shouldRepaint(FloodPainter oldDelegate) =>
      oldDelegate.floodLevel != floodLevel ||
      oldDelegate.waveOffset != waveOffset ||
      oldDelegate.isDanger != isDanger;
}