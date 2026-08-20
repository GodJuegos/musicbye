import 'package:flutter/services.dart';

import '../models/song.dart';

class MusicLibraryException implements Exception {
  const MusicLibraryException(this.message);

  final String message;
}

class MusicLibrary {
  static const MethodChannel _musicChannel = MethodChannel(
    'com.musicbye/library',
  );

  Future<List<Song>> readSongs() async {
    final hasPermission =
        await _musicChannel.invokeMethod<bool>('requestAudioPermission') ??
            false;

    if (!hasPermission) {
      throw const MusicLibraryException(
        'Necesitamos permiso para mostrar tu música local.',
      );
    }

    final rawSongs =
        await _musicChannel.invokeMethod<List<dynamic>>('getSongs') ??
            <dynamic>[];

    return rawSongs.map<Song>((rawSong) {
      final map = Map<Object?, Object?>.from(rawSong as Map);
      return Song.fromMap(map);
    }).toList();
  }
}