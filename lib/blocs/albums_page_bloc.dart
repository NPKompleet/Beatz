import 'dart:async';
import 'dart:collection';

import 'package:beatz/blocs/bloc_provider.dart';
import 'package:beatz/models/album.dart';
import 'package:beatz/services/platform_service.dart';
import 'package:rxdart/rxdart.dart';

class AlbumsPageBloc extends BlocBase {
  List<Album> _albumList = [];

  /// Stream to handle displaying albums
  BehaviorSubject<List<Album>> _listController = BehaviorSubject<List<Album>>();
  StreamSink<List<Album>> get _albumListSink => _listController.sink;
  Stream<List<Album>> get albumListStream => _listController.stream;

  AlbumsPageBloc() {
    _fetchAlbums();
  }

  Future<void> _fetchAlbums() async {
    _albumList = await PlatformService.fetchAlbums();
    _albumListSink.add(UnmodifiableListView<Album>(_albumList));
  }

  @override
  void dispose() {
    _listController.close();
  }
}
