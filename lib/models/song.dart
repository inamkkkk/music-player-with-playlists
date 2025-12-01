class Song {
  final String id;
  final String title;
  final String artist;
  final String uri;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.uri,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'uri': uri,
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      uri: map['uri'] ?? '',
    );
  }
}
