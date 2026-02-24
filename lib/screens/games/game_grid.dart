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
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridSize,
      ),
      itemCount: gridSize * gridSize,
      itemBuilder: (context, index) {
        int x = index % gridSize;
        int y = index ~/ gridSize;

        Position currentPos = Position(x, y);
        bool isSnakeHead = snake.isNotEmpty && snake.first == currentPos;
        bool isSnakeBody = snake.skip(1).contains(currentPos);
        bool isFood = food == currentPos;

        Color cellColor = Colors.transparent;
        Widget? cellChild;

        if (isSnakeHead) {
          cellColor = Colors.green;
          cellChild = const Icon(Icons.circle, color: Colors.white, size: 12);
        } else if (isSnakeBody) {
          cellColor = Colors.lightGreen;
        } else if (isFood) {
          cellColor = Colors.red;
          cellChild = const Icon(Icons.apple, color: Colors.white, size: 16);
        }

        return Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: cellColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: cellChild,
        );
      },
    );
  }
}