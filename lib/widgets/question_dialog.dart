import 'package:flutter/material.dart';
import '../../models/games_model.dart';
import '../../../config/app_theme.dart';
import '../../../widgets/glass_container.dart';

class QuestionDialog extends StatelessWidget {
  final FloodQuestion question;
  final Function(int) onAnswer;

  const QuestionDialog({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dim background
        Container(color: Colors.black54),
        // Question Card
        Center(
          child: GlassContainer(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.help_outline,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Flood Safety Question',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  question.question,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ...List.generate(
                  question.options.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => onAnswer(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.liquidPurple2,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(question.options[index]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}