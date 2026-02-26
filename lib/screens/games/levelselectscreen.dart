// views/level_select_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'survivalgameviewmodel.dart';
import '../../models/scenariorepo.dart';
import '../../models/survivalgamemodel.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SurvivalGameViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0A1628), Color(0xFF0D2137), Color(0xFF051020)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white70),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            'FLOOD SURVIVAL',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => vm.goToLeaderboard(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.amber.withOpacity(0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.emoji_events, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${vm.highScore}',
                                  style: const TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tagline
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Every choice determines your survival.\nLearn. Decide. Survive.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blue.shade200.withOpacity(0.7),
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Level Cards
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: ScenarioRepository.levels.length,
                      itemBuilder: (context, index) {
                        final level = ScenarioRepository.levels[index];
                        final isUnlocked = vm.isLevelUnlocked(level.levelNumber);
                        return _LevelCard(
                          level: level,
                          isUnlocked: isUnlocked,
                          onTap: isUnlocked
                              ? () => vm.startLevel(level.levelNumber)
                              : null,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LevelCard extends StatelessWidget {
  final GameLevel level;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.level,
    required this.isUnlocked,
    this.onTap,
  });

  static const _levelColors = [
    [Color(0xFF1565C0), Color(0xFF0D47A1)],
    [Color(0xFF6A1B9A), Color(0xFF4A148C)],
    [Color(0xFFB71C1C), Color(0xFF7F0000)],
  ];

  static const _levelIcons = ['🌧️', '🌊', '🚁'];

  @override
  Widget build(BuildContext context) {
    final colors = _levelColors[(level.levelNumber - 1) % _levelColors.length];
    final icon = _levelIcons[(level.levelNumber - 1) % _levelIcons.length];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isUnlocked
                ? colors
                : [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnlocked
                ? colors[0].withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: colors[0].withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Level icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: isUnlocked
                      ? Text(icon, style: const TextStyle(fontSize: 32))
                      : const Icon(Icons.lock, color: Colors.white38, size: 28),
                ),
              ),
              const SizedBox(width: 16),

              // Level info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'LEVEL ${level.levelNumber}',
                            style: TextStyle(
                              color: isUnlocked
                                  ? Colors.white70
                                  : Colors.white30,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            level.setting,
                            style: TextStyle(
                              color: isUnlocked
                                  ? Colors.white54
                                  : Colors.white24,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      level.title,
                      style: TextStyle(
                        color: isUnlocked ? Colors.white : Colors.white38,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isUnlocked
                          ? level.description
                          : 'Score ${level.pointsToUnlock}+ points to unlock',
                      style: TextStyle(
                        color: isUnlocked ? Colors.white60 : Colors.white30,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              if (isUnlocked)
                const Icon(Icons.play_arrow_rounded,
                    color: Colors.white70, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}