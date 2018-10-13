import 'dart:async';
import 'dart:convert';

import 'package:beatz/models/album.dart';
import 'package:flutter/services.dart';

class PlatformService {
  static const MethodChannel platform = MethodChannel('com.npkompleet.beatz');
  static final String _fetchAlbumMethod = 'fetchAlbums';
  static final String _fetchSongsFromAlbumMethod = 'fetchSongsFromAlbum';

  static Future<List<Album>> fetchAlbums() async {
    List<Album> albums = [];
    try {
      final result = await platform.invokeMethod(_fetchAlbumMethod);
      Iterable message = json.decode(result);
      message.forEach((e) => albums.add(Album.fromJson(e)));
    } on PlatformException catch (e) {
      print(e);
    }
    return albums;
  }
}
