import 'package:flutter/material.dart';

import '../../models/song.dart';

class TrackInformation extends StatelessWidget {
  const TrackInformation({
    super.key,
    required this.song,
  });

  final Song song;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          song.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          song.artist,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            IconButton(
              onPressed: null,
              tooltip: 'Favorito próximamente',
              icon: Icon(Icons.favorite_border_rounded),
            ),
            SizedBox(width: 18),
            IconButton(
              onPressed: null,
              tooltip: 'Opciones próximamente',
              icon: Icon(Icons.more_horiz_rounded),
            ),
          ],
        ),
      ],
    );
  }
}