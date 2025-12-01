import 'package:flutter/material.dart';
import 'package:music_player/models/playlist.dart';
import 'package:music_player/services/playlist_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/services/audio_player_service.dart';
import 'now_playing_screen.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlaylistScreen extends StatefulWidget {
  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final TextEditingController _playlistNameController = TextEditingController();
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> songs = [];

  @override
  void initState() {
    super.initState();
    fetchSongs();
  }

  Future<void> fetchSongs() async {
    songs = await _audioQuery.querySongs(sortType: null, orderType: null, uriType: UriType.EXTERNAL);
    setState(() {});
  }

  Future<void> _showCreatePlaylistDialog(BuildContext context) async {
    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: const Text('Create New Playlist'),
        content: TextField(
          controller: _playlistNameController,
          decoration: const InputDecoration(hintText: 'Playlist Name'),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Create'),
            onPressed: () {
              if (_playlistNameController.text.isNotEmpty) {
                Provider.of<PlaylistService>(context, listen: false).
                  createPlaylist(_playlistNameController.text);
                _playlistNameController.clear();
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    });
  }

  Future<void> _showAddSongToPlaylistDialog(BuildContext context, Playlist playlist) async {
    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: const Text('Add Song to Playlist'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return ListTile(
                title: Text(song.title),
                onTap: () {
                  Provider.of<PlaylistService>(context, listen: false).
                    addSongToPlaylist(playlist.id, Song(
                      id: song.id.toString(),
                      title: song.title,
                      artist: song.artist ?? 'Unknown',
                      uri: song.uri ?? '',
                    ));
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final playlistService = Provider.of<PlaylistService>(context);
    final audioPlayerService = Provider.of<AudioPlayerService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => _showCreatePlaylistDialog(context),
            child: const Text('Create New Playlist'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: playlistService.playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlistService.playlists[index];
                return Slidable(
                  key: Key(playlist.id),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          playlistService.deletePlaylist(playlist.id);
                        },
                        backgroundColor: const Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(playlist.name),
                    subtitle: Text('${playlist.songs.length} songs'),
                    onTap: () {
                      _showPlaylistSongs(context, playlist);
                    },
                    onLongPress: () {
                      _showAddSongToPlaylistDialog(context, playlist);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPlaylistSongs(BuildContext context, Playlist playlist) {
    final audioPlayerService = Provider.of<AudioPlayerService>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(playlist.name)),
          body: ListView.builder(
            itemCount: playlist.songs.length,
            itemBuilder: (context, index) {
              final song = playlist.songs[index];
              return ListTile(
                title: Text(song.title),
                subtitle: Text(song.artist),
                onTap: () {
                  List<Song> songList = playlist.songs;
                  List<SongModel> songModelList = [];

                  for (var s in songList) {
                    songModelList.add(SongModel({
                      '_id': int.parse(s.id),
                      'title': s.title,
                      'artist': s.artist,
                      'uri': s.uri,
                    }));
                  }

                  int initialIndex = index;

                  audioPlayerService.setAudioSource(
                    songModelList,
                    initialIndex,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NowPlayingScreen()),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
