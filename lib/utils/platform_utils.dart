import 'package:flutter/services.dart';

const MethodChannel platform = const MethodChannel('com.npkompleet.beatz');
final String fetchAlbumMethod = 'fetchAlbums';
final String fetchSongsFromAlbumMethod = 'fetchSongsFromAlbum';
