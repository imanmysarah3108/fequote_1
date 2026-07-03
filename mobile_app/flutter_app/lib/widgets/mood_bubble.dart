import 'dart:math';
import 'package:flutter/material.dart';

class MoodBubbleData {
  final String emotion;
  final Color color;
  final Offset alignment;
  final String emoji;

  const MoodBubbleData({
    required this.emotion,
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

  static const _minBubbleSize = 76.0;
  static const _maxBubbleSize = 96.0;

  static const _bubbleMeta = {
    'happy': MoodBubbleData(
      emotion: 'Happy',
      color: Color(0xFFFFD36E),
      alignment: Offset(0.5, 0.18),
      emoji: '😊',
    ),
    'sad': MoodBubbleData(
      emotion: 'Sad',
      color: Color(0xFF9E8BFF),
      alignment: Offset(0.22, 0.5),
      emoji: '😢',
    ),
    'surprise': MoodBubbleData(
      emotion: 'Surprise',
      color: Color(0xFFFF9EC7),
      alignment: Offset(0.78, 0.5),
      emoji: '😮',
    ),
    'angry': MoodBubbleData(
      emotion: 'Angry',
      color: Color(0xFFFF7A6E),
      alignment: Offset(0.5, 0.82),
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
    final clamped = percentage.clamp(0.0, 100.0);
    if (clamped <= 0) return _minBubbleSize;
    return _minBubbleSize + (clamped / 100) * (_maxBubbleSize - _minBubbleSize);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fieldHeight = constraints.maxWidth * 0.9;
        return SizedBox(
          height: fieldHeight.clamp(280.0, 340.0),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  ..._buildDecorativeOrbs(constraints.maxWidth, fieldHeight),
                  ..._bubbleMeta.entries.map((entry) {
                    final key = entry.key;
                    final meta = entry.value;
                    final percentage = widget.distribution[key] ?? 0;
                    final size = _bubbleSize(percentage);
                    final floatOffset =
                        sin(_controller.value * 2 * pi + key.hashCode) * 4;
                    final breathe = 1.0 +
                        sin(_controller.value * 2 * pi + key.hashCode * 0.5) * 0.025;

                    return Positioned(
                      left: meta.alignment.dx * constraints.maxWidth -
                          (size * breathe) / 2,
                      top: meta.alignment.dy * fieldHeight -
                          (size * breathe) / 2 +
                          floatOffset,
                      child: Transform.scale(
                        scale: breathe,
                        child: _MoodBubble(
                          label: meta.emotion,
                          percentage: percentage,
                          color: meta.color,
                          emoji: meta.emoji,
                          size: size,
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        );
      },
    );
  }

  List<Widget> _buildDecorativeOrbs(double width, double height) {
    const orbs = [
      (Offset(0.08, 0.3), 12.0, Color(0xFF9E8BFF)),
      (Offset(0.92, 0.25), 10.0, Color(0xFFFFB09C)),
      (Offset(0.12, 0.75), 8.0, Color(0xFFFF9EC7)),
      (Offset(0.88, 0.78), 14.0, Color(0xFF9E8BFF)),
    ];

    return orbs.map((orb) {
      final floatOffset = sin(_controller.value * 2 * pi + orb.$1.dx * 10) * 3;
      return Positioned(
        left: orb.$1.dx * width - orb.$2 / 2,
        top: orb.$1.dy * height - orb.$2 / 2 + floatOffset,
        child: Container(
          width: orb.$2,
          height: orb.$2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: orb.$3.withValues(alpha: 0.45),
            boxShadow: [
              BoxShadow(
                color: orb.$3.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      );
    }).toList();
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
            color.withValues(alpha: 0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 20,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(-3, -3),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.45), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: TextStyle(fontSize: size * 0.22)),
          SizedBox(height: size * 0.02),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: max(size * 0.11, 9),
            ),
          ),
          Text(
            '${percentage.round()}%',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
              fontSize: max(size * 0.1, 8),
            ),
          ),
        ],
      ),
    );
  }
}
