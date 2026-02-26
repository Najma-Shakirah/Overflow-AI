import 'package:flutter/material.dart';
import '../../../models/games_model.dart';

class GameControls extends StatelessWidget {
  final Function(Direction) onDirectionChange;

  const GameControls({
    super.key,
    required this.onDirectionChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Up
          _DpadButton(
            icon: Icons.keyboard_arrow_up_rounded,
            onTap: () => onDirectionChange(Direction.up),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left
              _DpadButton(
                icon: Icons.keyboard_arrow_left_rounded,
                onTap: () => onDirectionChange(Direction.left),
              ),
              const SizedBox(width: 48),
              // Right
              _DpadButton(
                icon: Icons.keyboard_arrow_right_rounded,
                onTap: () => onDirectionChange(Direction.right),
              ),
            ],
          ),
          // Down
          _DpadButton(
            icon: Icons.keyboard_arrow_down_rounded,
            onTap: () => onDirectionChange(Direction.down),
          ),
        ],
      ),
    );
  }
}

class _DpadButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _DpadButton({required this.icon, required this.onTap});

  @override
  State<_DpadButton> createState() => _DpadButtonState();
}

class _DpadButtonState extends State<_DpadButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        widget.onTap();
      },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: _pressed
              ? Colors.white.withOpacity(0.35)
              : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(_pressed ? 0.6 : 0.25),
            width: 1.5,
          ),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Icon(
          widget.icon,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}