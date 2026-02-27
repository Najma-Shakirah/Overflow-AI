// lib/screens/games/flood_rising_game_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/floodrisingmodel.dart';
import 'risinggameviewmodel.dart';
import 'floodpainter.dart';

class FloodRisingGamePage extends StatelessWidget {
  const FloodRisingGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FloodRisingViewModel(),
      child: const _FloodRisingGameView(),
    );
  }
}

class _FloodRisingGameView extends StatefulWidget {
  const _FloodRisingGameView();

  @override
  State<_FloodRisingGameView> createState() => _FloodRisingGameViewState();
}

class _FloodRisingGameViewState extends State<_FloodRisingGameView>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _shakeController;
  late AnimationController _pulseController;
  late Animation<double> _shakeAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Continuous wave motion
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Shake on wrong answer
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );

    // Pulse for danger zone
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _shakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FloodRisingViewModel>(
      builder: (context, vm, _) {
        // Trigger shake on wrong answer
        if (vm.gameState == FloodGameState.answerWrong) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _triggerShake());
        }

        return Scaffold(
          body: Stack(
            children: [
              // ── Sky background ─────────────────────────────────────────
              _SkyBackground(floodLevel: vm.floodLevel),

              // ── Animated flood water ───────────────────────────────────
              AnimatedBuilder(
                animation: _waveController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: FloodPainter(
                      floodLevel: vm.floodLevel,
                      waveOffset: _waveController.value * 2 * pi,
                      isDanger: vm.floodLevel > 0.65,
                    ),
                    child: const SizedBox.expand(),
                  );
                },
              ),

              // ── Buildings silhouette ───────────────────────────────────
              const _BuildingsSilhouette(),

              // ── Character / person on building ────────────────────────
              _CharacterWidget(
                floodLevel: vm.floodLevel,
                pulseAnim: _pulseAnim,
                isDanger: vm.floodLevel > 0.65,
              ),

              // ── Flood level indicator bar ─────────────────────────────
              _FloodLevelBar(floodLevel: vm.floodLevel),

              // ── Main content (question / UI) ───────────────────────────
              SafeArea(
                child: AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (context, child) {
                    final shake = sin(_shakeAnim.value * pi * 6) * 8;
                    return Transform.translate(
                      offset: Offset(shake, 0),
                      child: child,
                    );
                  },
                  child: _GameContent(vm: vm),
                ),
              ),

              // ── Overlays for game states ───────────────────────────────
              if (vm.gameState == FloodGameState.idle)
                _StartOverlay(onStart: () => vm.startGame()),

              if (vm.gameState == FloodGameState.gameOver)
                _GameOverOverlay(vm: vm),

              if (vm.gameState == FloodGameState.victory)
                _VictoryOverlay(vm: vm),
            ],
          ),
        );
      },
    );
  }
}

// ── Sky Background ────────────────────────────────────────────────────────────

class _SkyBackground extends StatelessWidget {
  final double floodLevel;
  const _SkyBackground({required this.floodLevel});

  @override
  Widget build(BuildContext context) {
    final isDanger = floodLevel > 0.65;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDanger
              ? [const Color(0xFF1A0000), const Color(0xFF3D0C02), const Color(0xFF7A1A00)]
              : floodLevel > 0.4
                  ? [const Color(0xFF0D1B3E), const Color(0xFF1B2B5E), const Color(0xFF2A3F7E)]
                  : [const Color(0xFF1A3A6B), const Color(0xFF1E4D8C), const Color(0xFF2E6BA8)],
        ),
      ),
    );
  }
}

// ── Buildings Silhouette ──────────────────────────────────────────────────────

class _BuildingsSilhouette extends StatelessWidget {
  const _BuildingsSilhouette();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: CustomPaint(
        size: Size(MediaQuery.of(context).size.width, 220),
        painter: _BuildingsPainter(),
      ),
    );
  }
}

class _BuildingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0A0F1A);
    final buildings = [
      // [left, width, height]
      [0.0, 60.0, 120.0],
      [55.0, 45.0, 160.0],
      [95.0, 70.0, 100.0],
      [160.0, 50.0, 180.0],
      [205.0, 55.0, 130.0],
      [255.0, 80.0, 150.0],
      [330.0, 45.0, 110.0],
      [370.0, 65.0, 170.0],
    ];

    for (final b in buildings) {
      // Windows
      final windowPaint = Paint()..color = const Color(0xFF1A3A6B).withOpacity(0.6);
      for (int row = 0; row < 5; row++) {
        for (int col = 0; col < (b[1] / 15).floor(); col++) {
          if ((row + col) % 2 == 0) {
            canvas.drawRect(
              Rect.fromLTWH(
                b[0] + col * 15 + 3,
                size.height - b[2] + row * 20 + 10,
                8, 10,
              ),
              windowPaint,
            );
          }
        }
      }
      canvas.drawRect(
        Rect.fromLTWH(b[0], size.height - b[2], b[1], b[2]),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BuildingsPainter old) => false;
}

// ── Character Widget ──────────────────────────────────────────────────────────

class _CharacterWidget extends StatelessWidget {
  final double floodLevel;
  final Animation<double> pulseAnim;
  final bool isDanger;

  const _CharacterWidget({
    required this.floodLevel,
    required this.pulseAnim,
    required this.isDanger,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Character sits on top of tallest building, rises above flood line
    final buildingTop = screenHeight - 175.0;
    final floodY = screenHeight * (1 - floodLevel);
    // Character Y: always above flood by at least a little
    final characterY = min(buildingTop, floodY - 60);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      top: characterY,
      right: 70,
      child: AnimatedBuilder(
        animation: pulseAnim,
        builder: (context, _) {
          return Transform.scale(
            scale: isDanger ? pulseAnim.value : 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Help sign
                if (isDanger)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'HELP!',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                if (isDanger) const SizedBox(height: 4),
                // Person emoji
                Text(
                  isDanger ? '🆘' : '🧍',
                  style: const TextStyle(fontSize: 28),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Flood Level Bar ───────────────────────────────────────────────────────────

class _FloodLevelBar extends StatelessWidget {
  final double floodLevel;
  const _FloodLevelBar({required this.floodLevel});

  @override
  Widget build(BuildContext context) {
    final isDanger = floodLevel > 0.65;
    return Positioned(
      right: 12,
      top: 100,
      bottom: 100,
      child: Container(
        width: 10,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Expanded(
              flex: ((1 - floodLevel) * 100).round(),
              child: Container(),
            ),
            Expanded(
              flex: (floodLevel * 100).round(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isDanger ? Colors.red.shade600 : Colors.blue.shade400,
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Game Content (question + choices) ────────────────────────────────────────

class _GameContent extends StatelessWidget {
  final FloodRisingViewModel vm;
  const _GameContent({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.gameState == FloodGameState.idle ||
        vm.gameState == FloodGameState.gameOver ||
        vm.gameState == FloodGameState.victory) {
      return const SizedBox.shrink();
    }

    final question = vm.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    final isAnswered = vm.isAnswerRevealed;
    final isDanger = vm.floodLevel > 0.65;

    return Column(
      children: [
        // ── Top bar ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.close, color: Colors.white70, size: 18),
                ),
              ),
              const SizedBox(width: 10),
              // Progress dots
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    FloodRisingViewModel.totalQuestions,
                    (i) => Container(
                      width: i == vm.currentQuestionNumber - 1 ? 16 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: i < vm.currentQuestionNumber - 1
                            ? Colors.green.shade400
                            : i == vm.currentQuestionNumber - 1
                                ? Colors.white
                                : Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Score
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${vm.stats.score}',
                      style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // ── Question + Choices card ───────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.72),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDanger
                    ? Colors.red.withOpacity(0.5)
                    : Colors.white.withOpacity(0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Timer + Question header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: Column(
                    children: [
                      // Timer bar
                      if (!isAnswered)
                        _TimerBar(
                          seconds: vm.timerSeconds,
                          totalSeconds: FloodRisingViewModel.questionTimerSeconds,
                          isDanger: isDanger,
                        ),

                      if (!isAnswered) const SizedBox(height: 10),

                      // Question number badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isDanger ? Colors.red : Colors.blue)
                              .withOpacity(0.25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (isDanger ? Colors.red : Colors.blue)
                                .withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          'QUESTION ${vm.currentQuestionNumber} / ${FloodRisingViewModel.totalQuestions}',
                          style: TextStyle(
                            color: isDanger
                                ? Colors.red.shade300
                                : Colors.blue.shade300,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Question text
                      Text(
                        question.question,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                Divider(
                    color: Colors.white.withOpacity(0.1),
                    height: 1,
                    thickness: 1),

                // Choices
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                  child: Column(
                    children: question.options.asMap().entries.map((entry) {
                      return _AnswerButton(
                        text: entry.value,
                        index: entry.key,
                        isAnswered: isAnswered,
                        isCorrect: vm.isCorrectAnswer(entry.key),
                        isWrongSelected: vm.isWrongSelected(entry.key),
                        isTimedOut: vm.selectedAnswerIndex == -1,
                        onTap: isAnswered
                            ? null
                            : () => vm.selectAnswer(entry.key),
                      );
                    }).toList(),
                  ),
                ),

                // Feedback
                if (isAnswered)
                  _FeedbackBar(
                    text: vm.feedbackText,
                    isCorrect: vm.gameState == FloodGameState.answerCorrect,
                    onContinue: () => vm.nextQuestion(),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Timer Bar ─────────────────────────────────────────────────────────────────

class _TimerBar extends StatelessWidget {
  final int seconds;
  final int totalSeconds;
  final bool isDanger;

  const _TimerBar({
    required this.seconds,
    required this.totalSeconds,
    required this.isDanger,
  });

  @override
  Widget build(BuildContext context) {
    final progress = seconds / totalSeconds;
    final isUrgent = seconds <= 5;

    return Row(
      children: [
        Icon(
          Icons.timer_rounded,
          color: isUrgent ? Colors.red : Colors.white60,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 6,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isUrgent
                      ? Colors.red
                      : progress > 0.5
                          ? Colors.green.shade400
                          : Colors.orange,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$seconds',
          style: TextStyle(
            color: isUrgent ? Colors.red : Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ── Answer Button ─────────────────────────────────────────────────────────────

class _AnswerButton extends StatefulWidget {
  final String text;
  final int index;
  final bool isAnswered;
  final bool isCorrect;
  final bool isWrongSelected;
  final bool isTimedOut;
  final VoidCallback? onTap;

  const _AnswerButton({
    required this.text,
    required this.index,
    required this.isAnswered,
    required this.isCorrect,
    required this.isWrongSelected,
    required this.isTimedOut,
    this.onTap,
  });

  @override
  State<_AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<_AnswerButton> {
  bool _pressed = false;

  Color get _bgColor {
    if (!widget.isAnswered) {
      return _pressed
          ? Colors.white.withOpacity(0.18)
          : Colors.white.withOpacity(0.08);
    }
    if (widget.isCorrect) return Colors.green.withOpacity(0.25);
    if (widget.isWrongSelected) return Colors.red.withOpacity(0.25);
    return Colors.white.withOpacity(0.04);
  }

  Color get _borderColor {
    if (!widget.isAnswered) {
      return _pressed
          ? Colors.white.withOpacity(0.5)
          : Colors.white.withOpacity(0.15);
    }
    if (widget.isCorrect) return Colors.green.shade400;
    if (widget.isWrongSelected) return Colors.red.shade400;
    return Colors.white.withOpacity(0.08);
  }

  @override
  Widget build(BuildContext context) {
    final labels = ['A', 'B', 'C', 'D'];

    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _borderColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: widget.isAnswered && widget.isCorrect
                    ? const Icon(Icons.check_rounded,
                        color: Colors.green, size: 16)
                    : widget.isAnswered && widget.isWrongSelected
                        ? const Icon(Icons.close_rounded,
                            color: Colors.red, size: 16)
                        : Text(
                            labels[widget.index],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.text,
                style: TextStyle(
                  color: widget.isAnswered && !widget.isCorrect &&
                          !widget.isWrongSelected
                      ? Colors.white30
                      : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Feedback Bar ──────────────────────────────────────────────────────────────

class _FeedbackBar extends StatelessWidget {
  final String text;
  final bool isCorrect;
  final VoidCallback onContinue;

  const _FeedbackBar({
    required this.text,
    required this.isCorrect,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isCorrect ? Colors.green : Colors.red).withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isCorrect ? Colors.green : Colors.red).withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isCorrect ? '✅ Correct!' : '❌ Wrong!',
                style: TextStyle(
                  color: isCorrect ? Colors.green.shade300 : Colors.red.shade300,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              if (isCorrect) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.water_drop, color: Colors.blue, size: 12),
                      SizedBox(width: 3),
                      Text('Flood dropped!',
                          style: TextStyle(color: Colors.blue, fontSize: 10)),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.water, color: Colors.red, size: 12),
                      SizedBox(width: 3),
                      Text('Flood rising!',
                          style: TextStyle(color: Colors.red, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
                color: Colors.white70, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isCorrect ? Colors.green.shade700 : Colors.red.shade800,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: onContinue,
              child: const Text(
                'Next Question →',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Start Overlay ─────────────────────────────────────────────────────────────

class _StartOverlay extends StatelessWidget {
  final VoidCallback onStart;
  const _StartOverlay({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🌊', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 20),
              const Text(
                'FLOOD RISING',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Answer correctly to hold back the flood.\nWrong answers raise the water level.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withOpacity(0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'If flood reaches the top — you\'re done!',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: onStart,
                  child: const Text(
                    'START GAME',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Game Over Overlay ─────────────────────────────────────────────────────────

class _GameOverOverlay extends StatelessWidget {
  final FloodRisingViewModel vm;
  const _GameOverOverlay({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💀', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              const Text(
                'SWEPT AWAY',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The flood overtook you.',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 24),
              _ScoreSummary(vm: vm),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Text(
                  '💡 Real floods don\'t give second chances. Learn flood safety — it saves lives.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.orange, fontSize: 12, height: 1.5),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Exit',
                          style: TextStyle(color: Colors.white54)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => vm.startGame(),
                      child: const Text(
                        'Try Again 🔄',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Victory Overlay ───────────────────────────────────────────────────────────

class _VictoryOverlay extends StatelessWidget {
  final FloodRisingViewModel vm;
  const _VictoryOverlay({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.82),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              const Text(
                'YOU SURVIVED!',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You held back the flood!\nYour knowledge saved lives.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white70, fontSize: 14, height: 1.6),
              ),
              const SizedBox(height: 24),
              _ScoreSummary(vm: vm),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Exit',
                          style: TextStyle(color: Colors.white54)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => vm.startGame(),
                      child: const Text(
                        'Play Again ⭐',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Score Summary ─────────────────────────────────────────────────────────────

class _ScoreSummary extends StatelessWidget {
  final FloodRisingViewModel vm;
  const _ScoreSummary({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _SummaryItem(icon: '⭐', label: 'Score', value: '${vm.stats.score}'),
          _Divider(),
          _SummaryItem(
              icon: '✅', label: 'Correct', value: '${vm.stats.correctAnswers}'),
          _Divider(),
          _SummaryItem(
              icon: '❌', label: 'Wrong', value: '${vm.stats.wrongAnswers}'),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  const _SummaryItem(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
        Text(label,
            style:
                const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 40, color: Colors.white.withOpacity(0.1));
  }
}