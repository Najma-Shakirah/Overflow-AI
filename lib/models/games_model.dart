class Position {
  final int x;
  final int y;
  
  Position(this.x, this.y);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position && x == other.x && y == other.y;
  
  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

enum Direction { up, down, left, right }

enum GameState { notStarted, playing, paused, gameOver, showingQuestion }

class FloodQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  FloodQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

class GameStats {
  final int score;
  final int snakeLength;
  final int correctAnswers;
  final int wrongAnswers;

  GameStats({
    this.score = 0,
    this.snakeLength = 1,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
  });

  GameStats copyWith({
    int? score,
    int? snakeLength,
    int? correctAnswers,
    int? wrongAnswers,
  }) {
    return GameStats(
      score: score ?? this.score,
      snakeLength: snakeLength ?? this.snakeLength,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
    );
  }
}