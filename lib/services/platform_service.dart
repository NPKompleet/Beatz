import 'dart:async';
import 'dart:convert';

import 'package:beatz/models/album.dart';
import 'package:beatz/models/audio_media.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PlatformService {
  static const MethodChannel _channel = MethodChannel('com.npkompleet.beatz');
  static const String _fetchAlbumMethod = 'fetchAlbums';
  static const String _fetchSongsFromAlbumMethod = 'fetchSongsFromAlbum';
  static const String _seekMethod = 'seek';
  static const String _pauseMethod = 'pause';
  static const String _resumeMethod = 'resume';
  static const String _playSongMethod = 'play';
  static const String _positionMethod = 'position';
  static const String _songCompleteMethod = "complete";
  static ValueNotifier<String> stopNotifier = ValueNotifier("");
  static ValueNotifier<int> positionNotifier = ValueNotifier(0);

  // Method handler for calls to be executed
  // on the Flutter side of the channel
  static Future<void> callHandler(MethodCall call) {
    switch (call.method) {
      case _songCompleteMethod:
        stopNotifier.value = "complete";
        print("completed");
        break;
      case _positionMethod:
        int position = call.arguments;
        positionNotifier.value = position;
        break;
    }
    return null;
  }

  static Future<List<Album>> fetchAlbums() async {
    String result = "";
    try {
      result = await _channel.invokeMethod(_fetchAlbumMethod);
    } on PlatformException catch (e) {
      print(e);
    }
    return compute(parseAlbums, result);
  }

  static List<Album> parseAlbums(String result) {
    List<Album> albums = [];
    Iterable message = json.decode(result);
    message.forEach((e) => albums.add(Album.fromJson(e)));
    return albums;
  }

  static Future<List<AudioMedia>> fetchSongsFromAlbum(int id) async {
    Map<String, int> albumInfo = {"albumId": id};
    String result = "";
    try {
      result =
          await _channel.invokeMethod(_fetchSongsFromAlbumMethod, albumInfo);
      print("Songs: $result");
    } on PlatformException catch (e) {
      print(e);
    }
    return compute(parseAlbumSongs, result);
  }

  static List<AudioMedia> parseAlbumSongs(String result) {
    List<AudioMedia> albumSongsList = [];
    Iterable message = json.decode(result);
    message.forEach((e) => albumSongsList.add(AudioMedia.fromJson(e)));
    return albumSongsList;
  }

  static Future<String> playSong(String url) async {
    _channel.setMethodCallHandler(callHandler);
    Map<String, String> songInfo = {"songUrl": url};
    String result = "";
    try {
      result = await _channel.invokeMethod(_playSongMethod, songInfo);
      print("Result was: $result");
    } on PlatformException catch (e) {
      print(e);
    }
    return result;
  }

  static Future<void> seekTo(int playbackPosition) async {
    await _channel.invokeMethod(_seekMethod, {"position": playbackPosition});
  }

  static Future<void> pauseSong() async {
    await _channel.invokeMethod(_pauseMethod);
  }

  static Future<void> resumeSong() async {
    await _channel.invokeMethod(_resumeMethod);
  }

  static void reset() {
    stopNotifier.value = "";
    positionNotifier.value = 0;
  }
}
