import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'loading_page/startup_loading_screen.dart';
import 'models/song.dart';
import 'player_page/now_playing_screen.dart';
import 'player_page/player_controller.dart';
import 'services/music_library.dart';

void main() {
  runApp(const MusicByeApp());
}

class MusicByeApp extends StatefulWidget {
  const MusicByeApp({super.key});

  @override
  State<MusicByeApp> createState() => _MusicByeAppState();
}

class _MusicByeAppState extends State<MusicByeApp> {
  final MusicLibrary _musicLibrary = MusicLibrary();
  final PlayerController _playerController = PlayerController();

  List<Song> _initialSongs = const [];
  String? _initialError;
  bool _isStarting = true;

  @override
  void initState() {
    super.initState();
    _startApplication();
  }

  Future<void> _startApplication() async {
    final startedAt = DateTime.now();

    try {
      _initialSongs = await _musicLibrary.readSongs();
    } on MusicLibraryException catch (error) {
      _initialError = error.message;
    } on PlatformException catch (error) {
      _initialError = error.message ?? 'No pudimos leer tu música.';
    } catch (_) {
      _initialError = 'Ocurrió un error inesperado.';
    }

    const minimumLoadingTime = Duration(seconds: 10);
    final elapsedTime = DateTime.now().difference(startedAt);
    final remainingTime = minimumLoadingTime - elapsedTime;

    if (remainingTime > Duration.zero) {
      await Future.delayed(remainingTime);
    }

    if (!mounted) return;

    setState(() {
      _isStarting = false;
    });
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MusicBye',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigoAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: _isStarting
          ? const StartupLoadingScreen()
          : LibraryScreen(
              initialSongs: _initialSongs,
              initialError: _initialError,
              playerController: _playerController,
            ),
    );
  }
}

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    super.key,
    required this.initialSongs,
    required this.playerController,
    this.initialError,
  });

  final List<Song> initialSongs;
  final String? initialError;
  final PlayerController playerController;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final MusicLibrary _musicLibrary = MusicLibrary();

  late List<Song> _songs;
  late String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _songs = widget.initialSongs;
    _errorMessage = widget.initialError;
  }

  Future<void> _loadSongs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final songs = await _musicLibrary.readSongs();

      if (!mounted) return;

      setState(() {
        _songs = songs;
      });
    } on MusicLibraryException catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.message;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.message ?? 'No pudimos leer tu música.';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Ocurrió un error inesperado.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _openPlayer(int songIndex) {
    widget.playerController.playFromQueue(_songs, songIndex);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return NowPlayingScreen(
            controller: widget.playerController,
          );
        },
      ),
    );
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MusicBye'),
        actions: [
          IconButton(
            tooltip: 'Actualizar biblioteca',
            onPressed: _isLoading ? null : _loadSongs,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.playerController,
        builder: (context, _) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (_songs.isEmpty) {
            return const Center(
              child: Text('No encontramos canciones en este dispositivo.'),
            );
          }

          return ListView.separated(
            itemCount: _songs.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final song = _songs[index];
              final isCurrentSong =
                  widget.playerController.currentSong?.id == song.id;
              final isPlaying =
                  isCurrentSong && widget.playerController.isPlaying;

              return ListTile(
                leading: CircleAvatar(
                  child: Icon(
                    isPlaying ? Icons.graphic_eq : Icons.music_note,
                  ),
                ),
                title: Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${song.artist} • ${song.album}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(_formatDuration(song.duration)),
                onTap: () => _openPlayer(index),
              );
            },
          );
        },
      ),
    );
  }
}