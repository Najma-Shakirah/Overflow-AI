// viewmodels/survival_game_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/survivalgamemodel.dart';
import '../../models/scenariorepo.dart';

enum SurvivalGamePhase {
  levelSelect,
  scenario,
  choiceFeedback,
  levelComplete,
  gameOver,
  leaderboard,
}

class SurvivalGameViewModel extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────
  SurvivalGamePhase _phase = SurvivalGamePhase.levelSelect;
  int _currentLevel = 1;
  int _currentScenarioIndex = 0;
  GameStat _stats = const GameStat(health: 100, supplies: 50, morale: 70, time: 100);
  int _totalScore = 0;
  int _highScore = 0;
  List<LeaderboardEntry> _leaderboard = [];
  String _playerName = 'Player';
  String? _lastFeedback;
  Choice? _lastChoice;
  List<int> _unlockedLevels = [1];

  // ── Getters ────────────────────────────────────────────────────────────
  SurvivalGamePhase get phase => _phase;
  int get currentLevel => _currentLevel;
  GameStat get stats => _stats;
  int get totalScore => _totalScore;
  int get highScore => _highScore;
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  String get playerName => _playerName;
  String? get lastFeedback => _lastFeedback;
  Choice? get lastChoice => _lastChoice;
  List<int> get unlockedLevels => _unlockedLevels;
  List<GameLevel> get allLevels => ScenarioRepository.levels;

  Scenario get currentScenario {
    final levelScenarios =
        ScenarioRepository.getScenariosForLevel(_currentLevel);
    return levelScenarios[_currentScenarioIndex];
  }

  int get scenarioProgress {
    return _currentScenarioIndex;
  }

  int get totalScenariosInLevel {
    return ScenarioRepository.getScenariosForLevel(_currentLevel).length;
  }

  double get progressPercent =>
      _currentScenarioIndex / totalScenariosInLevel;

  bool isLevelUnlocked(int level) => _unlockedLevels.contains(level);

  // ── Init ───────────────────────────────────────────────────────────────
  Future<void> init() async {
    await _loadProgress();
  }

  // ── Game Flow ──────────────────────────────────────────────────────────

  void startLevel(int level) {
    _currentLevel = level;
    _currentScenarioIndex = 0;
    _stats = const GameStat(health: 100, supplies: 50, morale: 70, time: 100);
    _totalScore = 0;
    _phase = SurvivalGamePhase.scenario;
    notifyListeners();
  }

  void makeChoice(Choice choice) {
    final effect = choice.effect;

    // Apply effects
    _stats = _stats.copyWith(
      health: _stats.health + effect.healthDelta,
      supplies: _stats.supplies + effect.suppliesDelta,
      morale: _stats.morale + effect.moraleDelta,
      time: _stats.time + effect.timeDelta,
    );

    // Score: base points + bonus for correct choices
    int scoreGain = 20;
    if (choice.isCorrect) scoreGain += 30;
    if (_stats.health > 70) scoreGain += 10;
    _totalScore += scoreGain;

    _lastChoice = choice;
    _lastFeedback = effect.feedbackText;
    _phase = SurvivalGamePhase.choiceFeedback;
    notifyListeners();
  }

  void continueFromFeedback() {
    if (_stats.isDead) {
      _phase = SurvivalGamePhase.gameOver;
      notifyListeners();
      return;
    }

    final levelScenarios =
        ScenarioRepository.getScenariosForLevel(_currentLevel);

    if (_currentScenarioIndex < levelScenarios.length - 1) {
      _currentScenarioIndex++;
      _phase = SurvivalGamePhase.scenario;
    } else {
      // Level complete
      _totalScore += _stats.totalScore; // bonus from remaining stats
      _phase = SurvivalGamePhase.levelComplete;

      // Unlock next level
      final nextLevel = _currentLevel + 1;
      if (nextLevel <= ScenarioRepository.levels.length &&
          !_unlockedLevels.contains(nextLevel)) {
        _unlockedLevels.add(nextLevel);
      }

      _saveProgress();
    }
    notifyListeners();
  }

  void goToLevelSelect() {
    _phase = SurvivalGamePhase.levelSelect;
    notifyListeners();
  }

  void goToLeaderboard() {
    _phase = SurvivalGamePhase.leaderboard;
    notifyListeners();
  }

  Future<void> submitScore(String name) async {
    _playerName = name;
    final entry = LeaderboardEntry(
      playerName: name,
      score: _totalScore,
      level: _currentLevel,
      completedAt: DateTime.now(),
    );
    _leaderboard.add(entry);
    _leaderboard.sort((a, b) => b.score.compareTo(a.score));
    if (_leaderboard.length > 10) _leaderboard = _leaderboard.take(10).toList();

    if (_totalScore > _highScore) _highScore = _totalScore;

    await _saveProgress();
    notifyListeners();
  }

  // ── Persistence ────────────────────────────────────────────────────────

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('high_score', _highScore);
    await prefs.setString('player_name', _playerName);
    await prefs.setString(
        'unlocked_levels', jsonEncode(_unlockedLevels));
    final leaderboardJson =
        jsonEncode(_leaderboard.map((e) => e.toMap()).toList());
    await prefs.setString('leaderboard', leaderboardJson);
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt('high_score') ?? 0;
    _playerName = prefs.getString('player_name') ?? 'Player';

    final unlockedJson = prefs.getString('unlocked_levels');
    if (unlockedJson != null) {
      _unlockedLevels = List<int>.from(jsonDecode(unlockedJson));
    }

    final leaderboardJson = prefs.getString('leaderboard');
    if (leaderboardJson != null) {
      final list = jsonDecode(leaderboardJson) as List;
      _leaderboard =
          list.map((e) => LeaderboardEntry.fromMap(e)).toList();
    }

    notifyListeners();
  }
}