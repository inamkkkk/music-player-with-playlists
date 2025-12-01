import 'package:music_player/models/song.dart';

class Playlist {
  final String id;
  final String name;
  final List<Song> songs;

  Playlist({
    required this.id,
    required this.name,
    this.songs = const [],
  });

  Playlist copyWith({
    String? id,
    String? name,
    List<Song>? songs,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      songs: songs ?? this.songs,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'songs': songs.map((x) => x.toMap()).toList(),
    };
  }

  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      songs: map['songs'] != null ? List<Song>.from(map['songs']?.map((x) => Song.fromMap(x))) : [],
    );
  }
}
