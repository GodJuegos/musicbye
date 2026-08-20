import 'package:flutter/material.dart';

import 'player_controller.dart';
import 'widgets/album_art_visualizer.dart';
import 'widgets/playback_controls.dart';
import 'widgets/playback_timeline.dart';
import 'widgets/track_information.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({
    super.key,
    required this.controller,
  });

  final PlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final song = controller.currentSong;

            if (song == null) {
              return const Center(
                child: Text('Selecciona una canción para reproducirla.'),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Volver a la biblioteca',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                      const Expanded(
                        child: Text(
                          'REPRODUCIENDO',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
                    child: Column(
                      children: [
                        AlbumArtVisualizer(
                          isPlaying: controller.isPlaying,
                        ),
                        const SizedBox(height: 30),
                        TrackInformation(song: song),
                        const SizedBox(height: 22),
                        PlaybackTimeline(controller: controller),
                        const SizedBox(height: 12),
                        PlaybackControls(controller: controller),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}