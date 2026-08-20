import 'package:flutter/material.dart';

import '../player_controller.dart';

class PlaybackControls extends StatelessWidget {
  const PlaybackControls({
    super.key,
    required this.controller,
  });

  final PlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              tooltip: 'Retroceder 10 segundos',
              iconSize: 34,
              onPressed: controller.skipBackTenSeconds,
              icon: const Icon(Icons.replay_10_rounded),
            ),
            IconButton(
              tooltip: 'Avanzar 10 segundos',
              iconSize: 34,
              onPressed: controller.skipForwardTenSeconds,
              icon: const Icon(Icons.forward_10_rounded),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              tooltip: 'Canción anterior',
              iconSize: 38,
              onPressed: controller.hasPrevious ? controller.previous : null,
              icon: const Icon(Icons.skip_previous_rounded),
            ),
            FilledButton(
              onPressed: controller.togglePlayPause,
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(22),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: Icon(
                controller.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                size: 48,
              ),
            ),
            IconButton(
              tooltip: 'Canción siguiente',
              iconSize: 38,
              onPressed: controller.hasNext ? controller.next : null,
              icon: const Icon(Icons.skip_next_rounded),
            ),
          ],
        ),
      ],
    );
  }
}