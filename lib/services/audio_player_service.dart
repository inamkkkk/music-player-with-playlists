import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudioPlayerService extends ChangeNotifier {
  final player = AudioPlayer();
  SongModel? currentSong;
  bool isPlaying = false;

  Future<void> setAudioSource(List<SongModel> songs, int index) async {
    currentSong = songs[index];
    final playlist = ConcatenatingAudioSource(
      children: songs.map((song) {
        return AudioSource.uri(
          Uri.parse(song.uri!),
          tag: MediaItem(
            id: song.id.toString(),
            title: song.title,
            artist: song.artist,
          ),
        );
      }).toList(),
    );
    await player.setAudioSource(playlist, initialIndex: index);
    play();
  }

  void play() {
    player.play();
    isPlaying = true;
    notifyListeners();
  }

  void pause() {
    player.pause();
    isPlaying = false;
    notifyListeners();
  }

  void seekToNext() {
    player.seekToNext();
  }

  void seekToPrevious() {
    player.seekToPrevious();
  }
}
