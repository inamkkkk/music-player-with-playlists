import 'package:flutter/material.dart';
import 'package:music_player/services/audio_player_service.dart';
import 'package:provider/provider.dart';

class NowPlayingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audioPlayerService = Provider.of<AudioPlayerService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(audioPlayerService.currentSong?.title ?? 'No song playing'),
            Text(audioPlayerService.currentSong?.artist ?? 'Unknown Artist'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: () {
                    audioPlayerService.seekToPrevious();
                  },
                ),
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
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () {
                    audioPlayerService.seekToNext();
                  },
                ),
              ],
            ),
            StreamBuilder<Duration>(
              stream: audioPlayerService.player.positionStream,
              builder: (context, snapshot) {
                final duration = snapshot.data ?? Duration.zero;
                return Text('Position: ${duration.inSeconds}s');
              },
            ),
          ],
        ),
      ),
    );
  }
}
