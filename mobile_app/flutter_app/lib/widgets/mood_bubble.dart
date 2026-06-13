import 'dart:math';
import 'package:flutter/material.dart';

class MoodBubbleData {
  final String emotion;
  final double percentage;
  final Color color;
  final Offset alignment;
  final String emoji;

  const MoodBubbleData({
    required this.emotion,
    required this.percentage,
    required this.color,
    required this.alignment,
    required this.emoji,
  });
}

class MoodBubbleField extends StatefulWidget {
  final Map<String, double> distribution;

  const MoodBubbleField({super.key, required this.distribution});

  @override
  State<MoodBubbleField> createState() => _MoodBubbleFieldState();
}

class _MoodBubbleFieldState extends State<MoodBubbleField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _bubbleMeta = {
    'happy': MoodBubbleData(
      emotion: 'Happy',
      percentage: 0,
      color: Color(0xFFFFD36E),
      alignment: Offset(0.5, 0.18),
      emoji: '😊',
    ),
    'sad': MoodBubbleData(
      emotion: 'Sad',
      percentage: 0,
      color: Color(0xFF9E8BFF),
      alignment: Offset(0.22, 0.48),
      emoji: '😢',
    ),
    'surprise': MoodBubbleData(
      emotion: 'Surprise',
      percentage: 0,
      color: Color(0xFFFF9EC7),
      alignment: Offset(0.78, 0.45),
      emoji: '😮',
    ),
    'angry': MoodBubbleData(
      emotion: 'Angry',
      percentage: 0,
      color: Color(0xFFFF7A6E),
      alignment: Offset(0.5, 0.78),
      emoji: '😠',
    ),
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _bubbleSize(double percentage) {
    if (percentage <= 0) return 56;
    return 56 + (percentage / 100) * 84;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Stack(
                clipBehavior: Clip.none,
                children: _bubbleMeta.entries.map((entry) {
                  final key = entry.key;
                  final meta = entry.value;
                  final percentage = widget.distribution[key] ?? 0;
                  final size = _bubbleSize(percentage);
                  final floatOffset = sin(_controller.value * 2 * pi + key.hashCode) * 6;

                  return Positioned(
                    left: meta.alignment.dx * constraints.maxWidth - size / 2,
                    top: meta.alignment.dy * constraints.maxHeight - size / 2 + floatOffset,
                    child: _MoodBubble(
                      label: meta.emotion,
                      percentage: percentage,
                      color: meta.color,
                      emoji: meta.emoji,
                      size: size,
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}

class _MoodBubble extends StatelessWidget {
  final String label;
  final double percentage;
  final Color color;
  final String emoji;
  final double size;

  const _MoodBubble({
    required this.label,
    required this.percentage,
    required this.color,
    required this.emoji,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.95),
            color.withValues(alpha: 0.55),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 24,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(-4, -4),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.45), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: TextStyle(fontSize: size * 0.22)),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: size * 0.11,
            ),
          ),
          Text(
            '${percentage.round()}%',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
              fontSize: size * 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
