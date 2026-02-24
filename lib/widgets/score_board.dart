import 'package:flutter/material.dart';
import '../../../models/games_model.dart';
import '../../../widgets/glass_container.dart';
import 'floodtipsscreen.dart';

class ScoreBoard extends StatelessWidget {
  final GameStats stats;
  final bool showTipsButton;

  const ScoreBoard({
    super.key,
    required this.stats,
    this.showTipsButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ScoreItem(label: 'Score', value: stats.score.toString()),
              _ScoreItem(label: 'Length', value: stats.snakeLength.toString()),
              _ScoreItem(
                label: 'Correct',
                value: stats.correctAnswers.toString(),
                color: Colors.green,
              ),
              _ScoreItem(
                label: 'Wrong',
                value: stats.wrongAnswers.toString(),
                color: Colors.red,
              ),
            ],
          ),
          
          // Tips Button
          if (showTipsButton) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FloodTipsScreen(
                        onContinue: () => Navigator.pop(context),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.lightbulb_outline, color: Colors.white),
                label: const Text(
                  'View Flood Safety Tips',
                  style: TextStyle(color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScoreItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _ScoreItem({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}