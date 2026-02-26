// flood_survival_game_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'survivalgameviewmodel.dart';
import 'levelselectscreen.dart';
import 'scenarioscreen.dart';
import 'resultscreen.dart';

class FloodSurvivalGamePage extends StatefulWidget {
  const FloodSurvivalGamePage({super.key});

  @override
  State<FloodSurvivalGamePage> createState() => _FloodSurvivalGamePageState();
}

class _FloodSurvivalGamePageState extends State<FloodSurvivalGamePage> {
  @override
  void initState() {
    super.initState();
    // Load saved progress after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SurvivalGameViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SurvivalGameViewModel(),
      child: const _GameRouter(),
    );
  }
}

class _GameRouter extends StatelessWidget {
  const _GameRouter();

  @override
  Widget build(BuildContext context) {
    return Consumer<SurvivalGameViewModel>(
      builder: (context, vm, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          child: _screenForPhase(vm.phase),
        );
      },
    );
  }

  Widget _screenForPhase(SurvivalGamePhase phase) {
    switch (phase) {
      case SurvivalGamePhase.levelSelect:
        return const LevelSelectScreen(key: ValueKey('levelSelect'));
      case SurvivalGamePhase.scenario:
        return const ScenarioScreen(key: ValueKey('scenario'));
      case SurvivalGamePhase.choiceFeedback:
        return const ChoiceFeedbackScreen(key: ValueKey('feedback'));
      case SurvivalGamePhase.levelComplete:
        return const LevelCompleteScreen(key: ValueKey('levelComplete'));
      case SurvivalGamePhase.gameOver:
        return const GameOverScreen(key: ValueKey('gameOver'));
      case SurvivalGamePhase.leaderboard:
        return const LeaderboardScreen(key: ValueKey('leaderboard'));
    }
  }
}