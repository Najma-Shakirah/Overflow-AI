// models/survival_game_model.dart

enum GameDifficulty { easy, medium, hard }

enum StatType { health, supplies, morale, time }

class GameStat {
  final int health;    // 0-100: physical condition
  final int supplies;  // 0-100: food/water/medicine
  final int morale;    // 0-100: mental state
  final int time;      // 0-100: time left to escape (counts down)

  const GameStat({
    required this.health,
    required this.supplies,
    required this.morale,
    required this.time,
  });

  GameStat copyWith({
    int? health,
    int? supplies,
    int? morale,
    int? time,
  }) {
    return GameStat(
      health: (health ?? this.health).clamp(0, 100),
      supplies: (supplies ?? this.supplies).clamp(0, 100),
      morale: (morale ?? this.morale).clamp(0, 100),
      time: (time ?? this.time).clamp(0, 100),
    );
  }

  bool get isDead => health <= 0 || time <= 0;

  int get totalScore => health + supplies + morale + time;
}

class ChoiceEffect {
  final int healthDelta;
  final int suppliesDelta;
  final int moraleDelta;
  final int timeDelta;
  final String? nextScenarioId; // null = next in sequence
  final String feedbackText;

  const ChoiceEffect({
    this.healthDelta = 0,
    this.suppliesDelta = 0,
    this.moraleDelta = 0,
    this.timeDelta = -10,
    this.nextScenarioId,
    required this.feedbackText,
  });
}

class Choice {
  final String text;
  final String icon;
  final ChoiceEffect effect;
  final bool isCorrect; // for scoring

  const Choice({
    required this.text,
    required this.icon,
    required this.effect,
    this.isCorrect = false,
  });
}

class Scenario {
  final String id;
  final String title;
  final String description;
  final String imageEmoji;    // big visual emoji for the scene
  final String backgroundType; // 'rain', 'flood', 'rescue', 'shelter'
  final List<Choice> choices;
  final int level;            // which level this belongs to
  final String educationalTip;

  const Scenario({
    required this.id,
    required this.title,
    required this.description,
    required this.imageEmoji,
    required this.backgroundType,
    required this.choices,
    required this.level,
    required this.educationalTip,
  });
}

class GameLevel {
  final int levelNumber;
  final String title;
  final String description;
  final String setting;
  final List<String> scenarioIds;
  final int pointsToUnlock;

  const GameLevel({
    required this.levelNumber,
    required this.title,
    required this.description,
    required this.setting,
    required this.scenarioIds,
    required this.pointsToUnlock,
  });
}

class LeaderboardEntry {
  final String playerName;
  final int score;
  final int level;
  final DateTime completedAt;

  const LeaderboardEntry({
    required this.playerName,
    required this.score,
    required this.level,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() => {
        'playerName': playerName,
        'score': score,
        'level': level,
        'completedAt': completedAt.toIso8601String(),
      };

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) =>
      LeaderboardEntry(
        playerName: map['playerName'],
        score: map['score'],
        level: map['level'],
        completedAt: DateTime.parse(map['completedAt']),
      );
}