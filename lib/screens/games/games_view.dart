import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../games/games_viewmodel.dart';
import '../../models/games_model.dart';
import '../../widgets/liquid_background.dart';
import '../../widgets/score_board.dart';
import 'game_grid.dart';
import '../../widgets/game_controls.dart';
import '../../widgets/start_screen.dart';
import '../../widgets/question_dialog.dart';

class SnakeGamePage extends StatelessWidget {
  const SnakeGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SnakeGameViewModel(),
      child: const _SnakeGameView(),
    );
  }
}

class _SnakeGameView extends StatelessWidget {
  const _SnakeGameView();

  void _showGameOverDialog(BuildContext context, GameStats stats) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Final Score: ${stats.score}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Snake Length: ${stats.snakeLength}'),
            Text('Correct Answers: ${stats.correctAnswers}'),
            Text('Wrong Answers: ${stats.wrongAnswers}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SnakeGameViewModel>().startGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _handleAnswer(BuildContext context, int index, bool isCorrect) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect ? '✓ Correct! +20 points' : '✗ Wrong! -5 points',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SnakeGameViewModel>(
      builder: (context, viewModel, child) {
        // Show game over dialog
        if (viewModel.isGameOver) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showGameOverDialog(context, viewModel.stats);
          });
        }

        return Scaffold(
          body: Stack(
            children: [
              LiquidBackground(
                gradientColors: const [
                  Color(0xFF667EEA),
                  Color(0xFF764BA2),
                  Color(0xFFFF6B6B),
                ],
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Text(
                              'Flood Safety Snake',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Score Board
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ScoreBoard(stats: viewModel.stats),
                      ),

                      const SizedBox(height: 16),

                      // Game Board
                      Expanded(
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              child: viewModel.gameState == GameState.notStarted
                                  ? StartScreen(
                                      onStart: () => viewModel.startGame(),
                                    )
                                  : GameGrid(
                                      snake: viewModel.snake,
                                      food: viewModel.food,
                                      gridSize: viewModel.gridSize,
                                    ),
                            ),
                          ),
                        ),
                      ),

                      // Controls
                      if (viewModel.isPlaying)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GameControls(
                            onDirectionChange: viewModel.changeDirection,
                          ),
                        ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Question Dialog
              if (viewModel.showingQuestion && viewModel.currentQuestion != null)
                QuestionDialog(
                  question: viewModel.currentQuestion!,
                  onAnswer: (index) {
                    bool isCorrect = index == viewModel.currentQuestion!.correctIndex;
                    viewModel.answerQuestion(index);
                    _handleAnswer(context, index, isCorrect);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}