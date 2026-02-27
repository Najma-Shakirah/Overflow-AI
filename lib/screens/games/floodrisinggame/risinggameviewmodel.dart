// lib/screens/games/flood_rising_viewmodel.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../models/floodrisingmodel.dart';
import '../../../models/floodrisingquestion.dart';

class FloodRisingViewModel extends ChangeNotifier {
  // ── Config ─────────────────────────────────────────────────────────────
  static const int totalQuestions = 10;
  static const double floodRiseOnWrong = 0.12;   // flood rises 12% on wrong
  static const double floodDropOnCorrect = 0.06; // flood drops 6% on correct
  static const double startingFloodLevel = 0.15; // starts at 15%
  static const double deathFloodLevel = 0.92;    // game over at 92%
  static const int questionTimerSeconds = 20;    // seconds to answer

  // ── State ──────────────────────────────────────────────────────────────
  FloodGameState _gameState = FloodGameState.idle;
  double _floodLevel = startingFloodLevel; // 0.0 = empty, 1.0 = full
  double _targetFloodLevel = startingFloodLevel;
  List<FloodQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  FloodRisingStats _stats = const FloodRisingStats();
  int? _selectedAnswerIndex;
  int _timerSeconds = questionTimerSeconds;
  Timer? _questionTimer;
  String _feedbackText = '';
  bool _showFeedback = false;

  // Animated flood level (interpolated by UI)
  double _animatedFloodLevel = startingFloodLevel;

  // ── Getters ────────────────────────────────────────────────────────────
  FloodGameState get gameState => _gameState;
  double get floodLevel => _animatedFloodLevel;
  double get targetFloodLevel => _targetFloodLevel;
  FloodQuestion? get currentQuestion =>
      _currentQuestionIndex < _questions.length
          ? _questions[_currentQuestionIndex]
          : null;
  FloodRisingStats get stats => _stats;
  int? get selectedAnswerIndex => _selectedAnswerIndex;
  int get timerSeconds => _timerSeconds;
  String get feedbackText => _feedbackText;
  bool get showFeedback => _showFeedback;
  int get currentQuestionNumber => _currentQuestionIndex + 1;
  double get progressPercent =>
      _currentQuestionIndex / totalQuestions;
  bool get isPlaying => _gameState == FloodGameState.playing;
  bool get isAnswerRevealed =>
      _gameState == FloodGameState.answerCorrect ||
      _gameState == FloodGameState.answerWrong;

  bool isCorrectAnswer(int index) =>
      currentQuestion != null && index == currentQuestion!.correctIndex;
  bool isWrongSelected(int index) =>
      _selectedAnswerIndex == index && _gameState == FloodGameState.answerWrong;

  // ── Game Control ───────────────────────────────────────────────────────

  void startGame() {
    _questions = FloodRisingQuestions.allShuffled().take(totalQuestions).toList();
    _currentQuestionIndex = 0;
    _floodLevel = startingFloodLevel;
    _targetFloodLevel = startingFloodLevel;
    _animatedFloodLevel = startingFloodLevel;
    _stats = const FloodRisingStats();
    _selectedAnswerIndex = null;
    _showFeedback = false;
    _gameState = FloodGameState.playing;
    _startQuestionTimer();
    notifyListeners();
  }

  void selectAnswer(int index) {
    if (!isPlaying) return;
    _questionTimer?.cancel();
    _selectedAnswerIndex = index;

    final question = currentQuestion!;
    final isCorrect = index == question.correctIndex;

    if (isCorrect) {
      _gameState = FloodGameState.answerCorrect;
      _targetFloodLevel = max(0.05, _floodLevel - floodDropOnCorrect);
      _feedbackText = question.explanation;
      _stats = _stats.copyWith(
        score: _stats.score + _calculateScore(),
        correctAnswers: _stats.correctAnswers + 1,
        questionsAnswered: _stats.questionsAnswered + 1,
      );
    } else {
      _gameState = FloodGameState.answerWrong;
      _targetFloodLevel = min(1.0, _floodLevel + floodRiseOnWrong);
      _feedbackText = question.explanation;
      _stats = _stats.copyWith(
        wrongAnswers: _stats.wrongAnswers + 1,
        questionsAnswered: _stats.questionsAnswered + 1,
      );
    }

    // Animate flood to target
    _animateFlood();

    // Check death condition
    if (_targetFloodLevel >= deathFloodLevel) {
      Future.delayed(const Duration(milliseconds: 1800), () {
        _gameState = FloodGameState.gameOver;
        notifyListeners();
      });
    }

    notifyListeners();
  }

  void nextQuestion() {
    if (_gameState == FloodGameState.gameOver) return;

    _currentQuestionIndex++;

    if (_currentQuestionIndex >= totalQuestions) {
      _gameState = FloodGameState.victory;
      notifyListeners();
      return;
    }

    _selectedAnswerIndex = null;
    _showFeedback = false;
    _gameState = FloodGameState.playing;
    _startQuestionTimer();
    notifyListeners();
  }

  void resetGame() {
    _questionTimer?.cancel();
    _gameState = FloodGameState.idle;
    _floodLevel = startingFloodLevel;
    _targetFloodLevel = startingFloodLevel;
    _animatedFloodLevel = startingFloodLevel;
    notifyListeners();
  }

  // ── Timer ──────────────────────────────────────────────────────────────

  void _startQuestionTimer() {
    _timerSeconds = questionTimerSeconds;
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        _timerSeconds--;
        notifyListeners();
      } else {
        // Time's up — treat as wrong answer
        timer.cancel();
        if (isPlaying && currentQuestion != null) {
          _handleTimeout();
        }
      }
    });
  }

  void _handleTimeout() {
    _selectedAnswerIndex = -1; // no answer selected
    _gameState = FloodGameState.answerWrong;
    _targetFloodLevel = min(1.0, _floodLevel + floodRiseOnWrong);
    _feedbackText = '⏰ Time\'s up! ${currentQuestion!.explanation}';
    _stats = _stats.copyWith(
      wrongAnswers: _stats.wrongAnswers + 1,
      questionsAnswered: _stats.questionsAnswered + 1,
    );
    _animateFlood();

    if (_targetFloodLevel >= deathFloodLevel) {
      Future.delayed(const Duration(milliseconds: 1800), () {
        _gameState = FloodGameState.gameOver;
        notifyListeners();
      });
    }

    notifyListeners();
  }

  // ── Flood Animation ────────────────────────────────────────────────────

  Timer? _floodAnimTimer;

  void _animateFlood() {
    _floodAnimTimer?.cancel();
    _floodAnimTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      final diff = _targetFloodLevel - _animatedFloodLevel;
      if (diff.abs() < 0.001) {
        _animatedFloodLevel = _targetFloodLevel;
        _floodLevel = _targetFloodLevel;
        timer.cancel();
      } else {
        _animatedFloodLevel += diff * 0.05;
      }
      notifyListeners();
    });
  }

  int _calculateScore() {
    // More points for faster answers and lower flood level
    final timeBonus = (_timerSeconds / questionTimerSeconds * 50).round();
    final floodBonus = ((1 - _floodLevel) * 30).round();
    return 50 + timeBonus + floodBonus;
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _floodAnimTimer?.cancel();
    super.dispose();
  }
}