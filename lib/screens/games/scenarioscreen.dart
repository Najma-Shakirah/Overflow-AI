// views/scenario_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'survivalgameviewmodel.dart';
import '../../models/survivalgamemodel.dart';

class ScenarioScreen extends StatefulWidget {
  const ScenarioScreen({super.key});

  @override
  State<ScenarioScreen> createState() => _ScenarioScreenState();
}

class _ScenarioScreenState extends State<ScenarioScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _fadeAnim =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
            parent: _entryController, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entryController, curve: Curves.easeOut));
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  void _onChoiceTap(SurvivalGameViewModel vm, Choice choice) {
    _entryController.reverse().then((_) {
      vm.makeChoice(choice);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SurvivalGameViewModel>(
      builder: (context, vm, _) {
        final scenario = vm.currentScenario;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: _backgroundGradient(scenario.backgroundType),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      // ── Top bar ────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => vm.goToLevelSelect(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.close,
                                    color: Colors.white70, size: 20),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Level ${vm.currentLevel} · Scene ${vm.scenarioProgress + 1}/${vm.totalScenariosInLevel}',
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 11),
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: vm.progressPercent,
                                      backgroundColor:
                                          Colors.white.withOpacity(0.15),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              Color(0xFF00E5FF)),
                                      minHeight: 4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.amber.withOpacity(0.4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${vm.totalScore}',
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

                      // ── Stat bars ──────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _StatBars(stats: vm.stats),
                      ),

                      const SizedBox(height: 16),

                      // ── Scene card ─────────────────────────────────────
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              // Scene visual
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.1)),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      scenario.imageEmoji,
                                      style: const TextStyle(fontSize: 64),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      scenario.title,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      scenario.description,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Choices
                              ...scenario.choices
                                  .asMap()
                                  .entries
                                  .map((entry) => _ChoiceButton(
                                        choice: entry.value,
                                        index: entry.key,
                                        onTap: () =>
                                            _onChoiceTap(vm, entry.value),
                                      )),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  LinearGradient _backgroundGradient(String type) {
    switch (type) {
      case 'flood':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1B2A), Color(0xFF1B3A5C), Color(0xFF0A4080)],
        );
      case 'rescue':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A0A2E), Color(0xFF2D1B69), Color(0xFF1A3A6B)],
        );
      case 'shelter':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D0D1A), Color(0xFF1A1A35), Color(0xFF0D2040)],
        );
      default: // rain
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A1520), Color(0xFF0D2030), Color(0xFF051525)],
        );
    }
  }
}

// ── Stat Bars ────────────────────────────────────────────────────────────────

class _StatBars extends StatelessWidget {
  final GameStat stats;
  const _StatBars({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          _StatBar(
              icon: '❤️', label: 'Health', value: stats.health, color: Colors.red.shade400),
          const SizedBox(width: 8),
          _StatBar(
              icon: '🎒', label: 'Supplies', value: stats.supplies, color: Colors.green.shade400),
          const SizedBox(width: 8),
          _StatBar(
              icon: '😊', label: 'Morale', value: stats.morale, color: Colors.blue.shade300),
          const SizedBox(width: 8),
          _StatBar(
              icon: '⏱️', label: 'Time', value: stats.time, color: Colors.orange.shade300),
        ],
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  final String icon;
  final String label;
  final int value;
  final Color color;

  const _StatBar({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(icon, style: const TextStyle(fontSize: 11)),
              Text(
                '$value',
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                value < 30 ? Colors.red : color,
              ),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Choice Button ─────────────────────────────────────────────────────────────

class _ChoiceButton extends StatefulWidget {
  final Choice choice;
  final int index;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.choice,
    required this.index,
    required this.onTap,
  });

  @override
  State<_ChoiceButton> createState() => _ChoiceButtonState();
}

class _ChoiceButtonState extends State<_ChoiceButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        transform: Matrix4.identity()
          ..scale(_pressed ? 0.97 : 1.0),
        decoration: BoxDecoration(
          color: _pressed
              ? Colors.white.withOpacity(0.15)
              : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _pressed
                ? Colors.white.withOpacity(0.4)
                : Colors.white.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child:
                    Text(widget.choice.icon, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.choice.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
            const Icon(Icons.chevron_right,
                color: Colors.white38, size: 20),
          ],
        ),
      ),
    );
  }
}