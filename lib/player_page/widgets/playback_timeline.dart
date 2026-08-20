import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../player_controller.dart';

class PlaybackTimeline extends StatelessWidget {
  const PlaybackTimeline({
    super.key,
    required this.controller,
  });

  final PlayerController controller;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final maximumMilliseconds = controller.duration.inMilliseconds;

    final currentMilliseconds = controller.position.inMilliseconds
        .clamp(0, maximumMilliseconds)
        .toDouble();

    final progress = maximumMilliseconds == 0
        ? 0.0
        : currentMilliseconds / maximumMilliseconds;

    return Column(
      children: [
        SizedBox(
          height: 58,
          child: Stack(
            alignment: Alignment.center,
            children: [
              IgnorePointer(
                child: CustomPaint(
                  size: Size(double.infinity, 58),
                  painter: _TimelineWavePainter(
                    progress: progress,
                  ),
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 7,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 18,
                  ),
                ),
                child: Slider(
                  value: maximumMilliseconds == 0 ? 0 : currentMilliseconds,
                  min: 0,
                  max: maximumMilliseconds == 0
                      ? 1
                      : maximumMilliseconds.toDouble(),
                  activeColor: const Color(0xFFFF5A1F),
                  inactiveColor: Colors.white24,
                  thumbColor: Colors.white,
                  onChanged: maximumMilliseconds == 0
                      ? null
                      : (value) {
                          controller.seek(
                            Duration(milliseconds: value.round()),
                          );
                        },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(controller.position)),
              Text(_formatDuration(controller.duration)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineWavePainter extends CustomPainter {
  const _TimelineWavePainter({
    required this.progress,
  });

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 58;
    const horizontalPadding = 12.0;

    final usableWidth = size.width - (horizontalPadding * 2);
    final centerY = size.height / 2;

    for (var index = 0; index < barCount; index++) {
      final ratio = index / (barCount - 1);
      final x = horizontalPadding + (usableWidth * ratio);

      final shape =
          (math.sin(index * 1.71) + math.sin(index * 0.43) + 2) / 4;

      final barHeight = 8 + (shape * 23);
      final isPlayed = ratio <= progress;

      final paint = Paint()
        ..color = isPlayed
            ? const Color(0xFFFF5A1F).withValues(alpha: 0.70)
            : Colors.white.withValues(alpha: 0.16)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.5;

      canvas.drawLine(
        Offset(x, centerY - (barHeight / 2)),
        Offset(x, centerY + (barHeight / 2)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimelineWavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}