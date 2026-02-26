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
    // Optimization: Create a Set of body positions (excluding head) 
    // This makes the 'contains' check nearly instant.
    final snakeBodySet = snake.length > 1 
        ? snake.skip(1).toSet() 
        : <Position>{};
    
    final snakeHead = snake.isNotEmpty ? snake.first : null;

    return GridView.builder(
      // Keep physics disabled to prevent accidental scrolling
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridSize,
      ),
      itemCount: gridSize * gridSize,
      itemBuilder: (context, index) {
        int x = index % gridSize;
        int y = index ~/ gridSize;

        Position currentPos = Position(x, y);
        
        // Logical checks
        bool isSnakeHead = snakeHead == currentPos;
        bool isSnakeBody = snakeBodySet.contains(currentPos);
        bool isFood = food == currentPos;

        // Styling logic
        Color cellColor = Colors.transparent;
        Widget? cellChild;

        if (isSnakeHead) {
          cellColor = Colors.green;
          cellChild = const Icon(Icons.circle, color: Colors.white, size: 12);
        } else if (isSnakeBody) {
          cellColor = Colors.lightGreen;
        } else if (isFood) {
          // Changed to an apple or droplet based on your theme
          cellChild = const Icon(
            Icons.water_drop, 
            color: Color.fromARGB(255, 88, 191, 235), 
            size: 16
          );
        }

        return Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            // Background color for the "empty" grid to make it visible
            color: cellColor == Colors.transparent 
                ? Colors.white.withOpacity(0.05) 
                : cellColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: cellChild,
        );
      },
    );
  }
}