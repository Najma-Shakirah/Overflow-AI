import 'package:flutter/material.dart';
import '../../../models/games_model.dart';

class GameGrid extends StatelessWidget {
  final List<Position> snake;
  final Position food;
  final int gridSize;

  const GameGrid({
    super.key,
    required this.snake,
    required this.food,
    required this.gridSize,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CustomPaint(
        painter: _SnakePainter(
          snake: snake,
          food: food,
          gridSize: gridSize,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A1628),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _SnakePainter extends CustomPainter {
  final List<Position> snake;
  final Position food;
  final int gridSize;

  _SnakePainter({
    required this.snake,
    required this.food,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / gridSize;
    final padding = cellSize * 0.08;

    // Draw grid dots (subtle)
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    for (int x = 0; x < gridSize; x++) {
      for (int y = 0; y < gridSize; y++) {
        canvas.drawCircle(
          Offset(x * cellSize + cellSize / 2, y * cellSize + cellSize / 2),
          1,
          dotPaint,
        );
      }
    }

    // Draw food (glowing apple)
    if (food != null) {
      _drawFood(canvas, food, cellSize);
    }

    // Draw snake body (back to front so head is on top)
    for (int i = snake.length - 1; i >= 1; i--) {
      _drawSnakeBody(canvas, snake[i], cellSize, padding, i, snake.length);
    }

    // Draw snake head
    if (snake.isNotEmpty) {
      _drawSnakeHead(canvas, snake.first, cellSize, padding);
    }
  }

  void _drawFood(Canvas canvas, Position pos, double cellSize) {
    final center = Offset(
      pos.x * cellSize + cellSize / 2,
      pos.y * cellSize + cellSize / 2,
    );
    final radius = cellSize * 0.38;

    // Glow effect
    final glowPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius * 1.5, glowPaint);

    // Food body
    final foodPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.red.shade300, Colors.red.shade700],
        center: const Alignment(-0.3, -0.3),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, foodPaint);

    // Shine
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx - radius * 0.25, center.dy - radius * 0.25),
      radius * 0.25,
      shinePaint,
    );

    // Stem
    final stemPaint = Paint()
      ..color = Colors.green.shade400
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx + radius * 0.3, center.dy - radius * 1.3),
      stemPaint,
    );
  }

  void _drawSnakeBody(Canvas canvas, Position pos, double cellSize,
      double padding, int index, int totalLength) {
    final rect = Rect.fromLTWH(
      pos.x * cellSize + padding,
      pos.y * cellSize + padding,
      cellSize - padding * 2,
      cellSize - padding * 2,
    );

    // Color gradient along body: bright green → darker green
    final t = index / totalLength;
    final color = Color.lerp(
      const Color(0xFF4CAF50),
      const Color(0xFF1B5E20),
      t,
    )!;

    final bodyPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(cellSize * 0.3)),
      bodyPaint,
    );

    // Inner highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(padding * 0.5),
        Radius.circular(cellSize * 0.25),
      ),
      highlightPaint,
    );
  }

  void _drawSnakeHead(
      Canvas canvas, Position pos, double cellSize, double padding) {
    final rect = Rect.fromLTWH(
      pos.x * cellSize + padding * 0.5,
      pos.y * cellSize + padding * 0.5,
      cellSize - padding,
      cellSize - padding,
    );

    // Head glow
    final glowPaint = Paint()
      ..color = const Color(0xFF76FF03).withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(2), Radius.circular(cellSize * 0.4)),
      glowPaint,
    );

    // Head body
    final headPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF76FF03), const Color(0xFF33691E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(cellSize * 0.4)),
      headPaint,
    );

    // Eyes
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final pupilPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final eyeOffset = cellSize * 0.18;
    final eyeRadius = cellSize * 0.1;
    final center = Offset(rect.center.dx, rect.center.dy);

    // Two eyes
    for (final sign in [-1.0, 1.0]) {
      final eyeCenter = Offset(center.dx + sign * eyeOffset, center.dy - eyeOffset * 0.5);
      canvas.drawCircle(eyeCenter, eyeRadius, eyePaint);
      canvas.drawCircle(
        Offset(eyeCenter.dx + 1, eyeCenter.dy + 1),
        eyeRadius * 0.55,
        pupilPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_SnakePainter oldDelegate) {
    return oldDelegate.snake != snake ||
        oldDelegate.food != food;
  }
}