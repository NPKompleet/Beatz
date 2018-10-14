import 'dart:async';
import 'dart:convert';

import 'package:beatz/models/album.dart';
import 'package:beatz/models/audio_media.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PlatformService {
  static const MethodChannel platform = MethodChannel('com.npkompleet.beatz');
  static final String _fetchAlbumMethodName = 'fetchAlbums';
  static final String _fetchSongsFromAlbumMethodName = 'fetchSongsFromAlbum';

  static Future<List<Album>> fetchAlbums() async {
//    List<Album> albums = [];
    String result = "";
    try {
      result = await platform.invokeMethod(_fetchAlbumMethodName);
//      Iterable message = json.decode(result);
//      message.forEach((e) => albums.add(Album.fromJson(e)));
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
      result = await platform.invokeMethod(
          _fetchSongsFromAlbumMethodName, albumInfo);
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
}
