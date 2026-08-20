import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/song.dart';

class PlayerController extends ChangeNotifier {
  PlayerController() {
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    _player.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    _player.durationStream.listen((duration) {
      if (duration != null) {
        _duration = duration;
        notifyListeners();
      }
    });

    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _handleSongCompleted();
      }
    });
  }

  final AudioPlayer _player = AudioPlayer();

  List<Song> _queue = const [];
  int _currentIndex = -1;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;

  Song? get currentSong {
    if (_currentIndex < 0 || _currentIndex >= _queue.length) {
      return null;
    }

    return _queue[_currentIndex];
  }

  Duration get position => _position;
  Duration get duration => _duration;
  bool get isPlaying => _isPlaying;
  bool get hasPrevious => _currentIndex > 0;
  bool get hasNext => _currentIndex >= 0 && _currentIndex < _queue.length - 1;

  Future<void> playFromQueue(
    List<Song> songs,
    int startIndex,
  ) async {
    if (songs.isEmpty || startIndex < 0 || startIndex >= songs.length) {
      return;
    }

    _queue = List.unmodifiable(songs);
    _currentIndex = startIndex;
    _position = Duration.zero;
    _duration = Duration(milliseconds: _queue[_currentIndex].duration);

    notifyListeners();

    await _loadCurrentSongAndPlay();
  }

  Future<void> _loadCurrentSongAndPlay() async {
    final song = currentSong;

    if (song == null) {
      return;
    }

    try {
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(song.uri)),
      );

      await _player.play();
    } on PlayerException {
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (currentSong == null) {
      return;
    }

    if (_player.playing) {
      await _player.pause();
      return;
    }

    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
    }

    await _player.play();
  }

  Future<void> seek(Duration newPosition) async {
    final maximumMilliseconds = _duration.inMilliseconds;
    final requestedMilliseconds = newPosition.inMilliseconds;

    final safeMilliseconds = requestedMilliseconds
        .clamp(0, maximumMilliseconds)
        .toInt();

    await _player.seek(
      Duration(milliseconds: safeMilliseconds),
    );
  }

  Future<void> skipForwardTenSeconds() async {
    await seek(_position + const Duration(seconds: 10));
  }

  Future<void> skipBackTenSeconds() async {
    await seek(_position - const Duration(seconds: 10));
  }

  Future<void> next() async {
    if (!hasNext) {
      return;
    }

    _currentIndex++;
    _position = Duration.zero;
    _duration = Duration(milliseconds: currentSong!.duration);

    notifyListeners();

    await _loadCurrentSongAndPlay();
  }

  Future<void> previous() async {
    if (_position > const Duration(seconds: 3)) {
      await seek(Duration.zero);
      return;
    }

    if (!hasPrevious) {
      await seek(Duration.zero);
      return;
    }

    _currentIndex--;
    _position = Duration.zero;
    _duration = Duration(milliseconds: currentSong!.duration);

    notifyListeners();

    await _loadCurrentSongAndPlay();
  }

  Future<void> _handleSongCompleted() async {
    if (hasNext) {
      await next();
      return;
    }

    await _player.seek(Duration.zero);
    await _player.pause();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}