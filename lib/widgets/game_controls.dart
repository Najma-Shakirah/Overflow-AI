import 'package:flutter/material.dart';
import '../../models/games_model.dart';
import '../../../widgets/glass_container.dart';

class GameControls extends StatelessWidget {
  final Function(Direction) onDirectionChange;

  const GameControls({
    super.key,
    required this.onDirectionChange,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Up button
          IconButton(
            icon: const Icon(Icons.arrow_upward, color: Colors.white, size: 32),
            onPressed: () => onDirectionChange(Direction.up),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left button
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                onPressed: () => onDirectionChange(Direction.left),
              ),
              const SizedBox(width: 60),
              // Right button
              IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 32),
                onPressed: () => onDirectionChange(Direction.right),
              ),
            ],
          ),
          // Down button
          IconButton(
            icon: const Icon(Icons.arrow_downward, color: Colors.white, size: 32),
            onPressed: () => onDirectionChange(Direction.down),
          ),
        ],
      ),
    );
  }
}