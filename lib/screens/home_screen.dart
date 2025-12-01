import 'package:flutter/material.dart';
import 'package:music_player/services/audio_player_service.dart';
import 'package:music_player/services/playlist_service.dart';
import 'package:provider/provider.dart';
import 'playlist_screen.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'now_playing_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> songs = [];

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
  }

  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    fetchSongs();
  }

  Future<void> fetchSongs() async {
    songs = await _audioQuery.querySongs(sortType: null, orderType: null, uriType: UriType.EXTERNAL);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioPlayerService = Provider.of<AudioPlayerService>(context);
    final playlistService = Provider.of<PlaylistService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Player'),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PlaylistScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return ListTile(
                  title: Text(song.title),
                  subtitle: Text(song.artist ?? 'Unknown Artist'),
                  onTap: () {
                    audioPlayerService.setAudioSource(
songs,
 index
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
          if (audioPlayerService.isPlaying) // Show mini player when a song is playing
            Container(
              height: 60,
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(audioPlayerService.currentSong?.title ?? 'No song playing'),
                  IconButton(
                    icon: Icon(audioPlayerService.isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      if (audioPlayerService.isPlaying) {
                        audioPlayerService.pause();
                      } else {
                        audioPlayerService.play();
                      }
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
