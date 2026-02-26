// lib/models/flood_rising_model.dart

class FloodQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final int level; // 1, 2, 3

  const FloodQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.level,
  });
}

class FloodRisingStats {
  final int score;
  final int correctAnswers;
  final int wrongAnswers;
  final int questionsAnswered;

  const FloodRisingStats({
    this.score = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.questionsAnswered = 0,
  });

  FloodRisingStats copyWith({
    int? score,
    int? correctAnswers,
    int? wrongAnswers,
    int? questionsAnswered,
  }) {
    return FloodRisingStats(
      score: score ?? this.score,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
    );
  }
}

enum FloodGameState { idle, playing, answerCorrect, answerWrong, gameOver, victory }