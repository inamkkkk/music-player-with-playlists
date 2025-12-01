import 'package:flutter/foundation.dart';
import 'package:music_player/models/playlist.dart';
import 'package:music_player/models/song.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class PlaylistService extends ChangeNotifier {
  List<Playlist> _playlists = [];
  List<Playlist> get playlists => _playlists;

  final String _databaseName = 'music_player.db';
  final String _playlistTable = 'playlists';
  final String _songTable = 'songs';

  Database? _database;

  PlaylistService() {
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, _databaseName);

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    await _loadPlaylists();
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_playlistTable (
        id TEXT PRIMARY KEY,
        name TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE $_songTable (
        id TEXT PRIMARY KEY,
        playlistId TEXT,
        title TEXT,
        artist TEXT,
        uri TEXT,
        FOREIGN KEY (playlistId) REFERENCES $_playlistTable(id)
      )
    ''');
  }

  Future<void> _loadPlaylists() async {
    if (_database == null) return;
    final List<Map<String, dynamic>> playlistMaps = await _database!.query(_playlistTable);

    _playlists = [];

    for (var playlistMap in playlistMaps) {
      final playlistId = playlistMap['id'] as String;

      final List<Map<String, dynamic>> songMaps = await _database!.query(
        _songTable,
        where: 'playlistId = ?',
        whereArgs: [playlistId],
      );

      final songs = songMaps.map((songMap) => Song.fromMap(songMap)).toList();

      _playlists.add(
        Playlist(
          id: playlistId,
          name: playlistMap['name'] as String,
          songs: songs,
        ),
      );
    }

    notifyListeners();
  }

  Future<void> createPlaylist(String name) async {
    if (_database == null) return;
    final id = const Uuid().v4();
    await _database!.insert(
      _playlistTable,
      {'id': id, 'name': name},
    );

    _playlists.add(Playlist(id: id, name: name));
    notifyListeners();
  }

  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    if (_database == null) return;
    await _database!.insert(
      _songTable,
      {
        'id': song.id,
        'playlistId': playlistId,
        'title': song.title,
        'artist': song.artist,
        'uri': song.uri,
      },
    );

    final playlistIndex = _playlists.indexWhere((playlist) => playlist.id == playlistId);
    if (playlistIndex != -1) {
      _playlists[playlistIndex] = _playlists[playlistIndex].copyWith(
        songs: List.from(_playlists[playlistIndex].songs)..add(song),
      );
    }

    notifyListeners();
  }

  Future<void> deletePlaylist(String playlistId) async {
    if (_database == null) return;
    await _database!.delete(
      _playlistTable,
      where: 'id = ?',
      whereArgs: [playlistId],
    );
    await _database!.delete(
      _songTable,
      where: 'playlistId = ?',
      whereArgs: [playlistId],
    );
    _playlists.removeWhere((playlist) => playlist.id == playlistId);
    notifyListeners();
  }
}
