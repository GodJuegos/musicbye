import 'dart:math' as math;

import 'package:flutter/material.dart';

class AlbumArtVisualizer extends StatefulWidget {
  const AlbumArtVisualizer({
    super.key,
    required this.isPlaying,
  });

  final bool isPlaying;

  @override
  State<AlbumArtVisualizer> createState() => _AlbumArtVisualizerState();
}

class _AlbumArtVisualizerState extends State<AlbumArtVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (widget.isPlaying) {
      _waveController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AlbumArtVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPlaying && !oldWidget.isPlaying) {
      _waveController.repeat();
    }

    if (!widget.isPlaying && oldWidget.isPlaying) {
      _waveController.stop();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        return SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size.square(300),
                painter: _CircularWavePainter(
                  phase: _waveController.value,
                  isPlaying: widget.isPlaying,
                ),
              ),
              Container(
                width: 190,
                height: 190,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF7D4CFF),
                      Color(0xFFEF4F8B),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 24,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.music_note_rounded,
                  color: Colors.white,
                  size: 88,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CircularWavePainter extends CustomPainter {
  const _CircularWavePainter({
    required this.phase,
    required this.isPlaying,
  });

  final double phase;
  final bool isPlaying;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const barCount = 76;

    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, 118, ringPaint);

    for (var index = 0; index < barCount; index++) {
      final angle = -math.pi / 2 + (index / barCount) * math.pi * 2;

      final movingPattern =
          (math.sin((index * 0.70) + (phase * math.pi * 4)) + 1) / 2;

      final barHeight = isPlaying
          ? 9 + (movingPattern * 22)
          : 9 + (((math.sin(index * 0.70) + 1) / 2) * 7);

      final barPaint = Paint()
        ..color = Color.lerp(
          const Color(0xFFFF5A1F),
          const Color(0xFFBA7CFF),
          movingPattern,
        )!
            .withValues(alpha: isPlaying ? 0.90 : 0.48)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3.2;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      canvas.drawLine(
        Offset(0, -124),
        Offset(0, -124 - barHeight),
        barPaint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CircularWavePainter oldDelegate) {
    return oldDelegate.phase != phase || oldDelegate.isPlaying != isPlaying;
  }
}