class Song {
  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.uri,
  });

  final int id;
  final String title;
  final String artist;
  final String album;
  final int duration;
  final String uri;

  factory Song.fromMap(Map<Object?, Object?> map) {
    return Song(
      id: map['id'] as int,
      title: map['title'] as String,
      artist: map['artist'] as String,
      album: map['album'] as String,
      duration: map['duration'] as int,
      uri: map['uri'] as String,
    );
  }
}