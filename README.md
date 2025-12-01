# Music Player with Playlists

A Flutter-based music player application that supports creating and managing playlists.

## Features

*   Play music from local storage.
*   Create, edit, and delete playlists.
*   Add songs to playlists.
*   Play songs from selected playlists.
*   Background audio playback.

## Dependencies

*   `provider`: For state management.
*   `just_audio`: For audio playback.
*   `just_audio_background`: For background audio playback.
*   `path_provider`: To get device's document directory.
*   `sqflite`: For local database to store playlists and songs.
*   `permission_handler`: To request storage permissions.
*   `on_audio_query`: To query local audio files.
*   `flutter_slidable`: To implement sliding actions on playlist items
*   `uuid`: To generate unique ids for playlists and songs

## Folder Structure


lib/
├── main.dart
├── screens/
│   ├── home_screen.dart
│   ├── playlist_screen.dart
│   ├── now_playing_screen.dart
├── models/
│   ├── song.dart
│   ├── playlist.dart
├── services/
│   ├── audio_player_service.dart
│   ├── playlist_service.dart
│   ├── database_service.dart


## Getting Started

1.  Clone the repository.
2.  Run `flutter pub get` to install dependencies.
3.  Run `flutter run` to start the application.
