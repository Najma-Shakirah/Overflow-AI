import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math';
import '../../models/games_model.dart';
import '../../models/floodquestionrepo.dart';

class SnakeGameViewModel extends ChangeNotifier {
  final int gridSize = 20;
  final int gameSpeed = 180; // Faster = smoother feel (was 300)
  final int applePoints = 10;
  final int correctAnswerBonus = 20;
  final int wrongAnswerPenalty = 5;

  final FloodQuestionsRepository _questionsRepository = FloodQuestionsRepository();

  List<Position> _snake = [Position(10, 10)];
  Position _food = Position(15, 15);
  Direction _direction = Direction.right;
  Direction _nextDirection = Direction.right;
  GameState _gameState = GameState.notStarted;
  GameStats _stats = GameStats();
  FloodQuestion? _currentQuestion;
  Timer? _gameTimer;

  List<Position> get snake => List.unmodifiable(_snake);
  Position get food => _food;
  Direction get direction => _direction;
  GameState get gameState => _gameState;
  GameStats get stats => _stats;
  FloodQuestion? get currentQuestion => _currentQuestion;

  bool get isPlaying => _gameState == GameState.playing;
  bool get isPaused => _gameState == GameState.paused;
  bool get isGameOver => _gameState == GameState.gameOver;
  bool get showingQuestion => _gameState == GameState.showingQuestion;

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void startGame() {
    _snake = [
      Position(12, 10),
      Position(11, 10),
      Position(10, 10),
    ]; // Start with 3 segments so snake is visible
    _food = _generateFood();
    _direction = Direction.right;
    _nextDirection = Direction.right;
    _gameState = GameState.playing;
    _stats = GameStats();
    _currentQuestion = null;

    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(
      Duration(milliseconds: gameSpeed),
      (timer) => _updateGame(),
    );

    notifyListeners();
  }

  void pauseGame() {
    if (_gameState == GameState.playing) {
      _gameState = GameState.paused;
      _gameTimer?.cancel();
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_gameState == GameState.paused) {
      _gameState = GameState.playing;
      _gameTimer = Timer.periodic(
        Duration(milliseconds: gameSpeed),
        (timer) => _updateGame(),
      );
      notifyListeners();
    }
  }

  void changeDirection(Direction newDirection) {
    if (_direction == Direction.up && newDirection == Direction.down) return;
    if (_direction == Direction.down && newDirection == Direction.up) return;
    if (_direction == Direction.left && newDirection == Direction.right) return;
    if (_direction == Direction.right && newDirection == Direction.left) return;
    _nextDirection = newDirection;
  }

  void answerQuestion(int selectedIndex) {
    if (_currentQuestion == null) return;

    bool isCorrect = selectedIndex == _currentQuestion!.correctIndex;

    if (isCorrect) {
      _stats = _stats.copyWith(
        correctAnswers: _stats.correctAnswers + 1,
        score: _stats.score + correctAnswerBonus,
      );
    } else {
      _stats = _stats.copyWith(
        wrongAnswers: _stats.wrongAnswers + 1,
        score: max(0, _stats.score - wrongAnswerPenalty),
      );
    }

    _food = _generateFood();
    _gameState = GameState.playing;
    _currentQuestion = null;

    // Resume timer
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(
      Duration(milliseconds: gameSpeed),
      (timer) => _updateGame(),
    );

    notifyListeners();
  }

  void _updateGame() {
    if (_gameState != GameState.playing) return;

    _direction = _nextDirection;

    Position newHead = _getNewHead();

    if (_isOutOfBounds(newHead)) {
      _endGame();
      return;
    }

    if (_snake.contains(newHead)) {
      _endGame();
      return;
    }

    _snake.insert(0, newHead);

    if (newHead == _food) {
      _stats = _stats.copyWith(
        score: _stats.score + applePoints,
      );
      _gameTimer?.cancel(); // Pause while showing question
      _showQuestion();
    } else {
      _snake.removeLast();
    }

    notifyListeners();
  }

  Position _getNewHead() {
    Position head = _snake.first;
    switch (_direction) {
      case Direction.up:
        return Position(head.x, head.y - 1);
      case Direction.down:
        return Position(head.x, head.y + 1);
      case Direction.left:
        return Position(head.x - 1, head.y);
      case Direction.right:
        return Position(head.x + 1, head.y);
    }
  }

  bool _isOutOfBounds(Position pos) {
    return pos.x < 0 || pos.x >= gridSize || pos.y < 0 || pos.y >= gridSize;
  }

  Position _generateFood() {
    Random random = Random();
    Position newFood;
    do {
      newFood = Position(random.nextInt(gridSize), random.nextInt(gridSize));
    } while (_snake.contains(newFood));
    return newFood;
  }

  void _showQuestion() {
    _gameState = GameState.showingQuestion;
    _currentQuestion = _questionsRepository.getRandomQuestion();
    notifyListeners();
  }

  void _endGame() {
    _gameTimer?.cancel();
    _gameState = GameState.gameOver;
    notifyListeners();
  }
}