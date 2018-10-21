import 'dart:async';
import 'dart:convert';

import 'package:beatz/models/album.dart';
import 'package:beatz/models/audio_media.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PlatformService {
  static const MethodChannel channel = MethodChannel('com.npkompleet.beatz');
  static const String _fetchAlbumMethod = 'fetchAlbums';
  static const String _fetchSongsFromAlbumMethod = 'fetchSongsFromAlbum';
  static const String _playSongMethod = 'play';
  static const String _positionMethod = 'position';
  static const String _songCompleteMethod = "complete";
  static ValueNotifier<String> stopAnimNotifier;

  // Method handler for calls to be executed
  // on the Flutter side of the channel
  static Future<Null> callHandler(MethodCall call) {
    switch (call.method) {
      case _songCompleteMethod:
        stopAnimNotifier.value = "complete";
        print("completed");
        break;
    }
  }

  static Future<List<Album>> fetchAlbums() async {
    String result = "";
    try {
      result = await channel.invokeMethod(_fetchAlbumMethod);
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
    print("AlbumID: $id");
    String result = "";
    try {
      result =
          await channel.invokeMethod(_fetchSongsFromAlbumMethod, albumInfo);
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
    channel.setMethodCallHandler(callHandler);
    Map<String, String> songInfo = {"songUrl": url};
    String result = "";
    try {
      result = await channel.invokeMethod(_playSongMethod, songInfo);
      print("Result was: $result");
    } on PlatformException catch (e) {
      print(e);
    }
    return result;
  }

  static Future<int> getPlaybackPosition() async {
    int result = 0;
    try {
      result = await channel.invokeMethod(_positionMethod);
      print("Position was: $result");
    } on PlatformException catch (e) {
      print(e);
    }
    return result;
  }
}
