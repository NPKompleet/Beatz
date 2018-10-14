import 'dart:async';
import 'dart:collection';

import 'package:beatz/blocs/bloc_provider.dart';
import 'package:beatz/models/audio_media.dart';
import 'package:beatz/services/platform_service.dart';

class CurrentPlayingBloc extends BlocBase {
  List<AudioMedia> _albumSongsList = [];

  /// Stream to handle displaying songs
  StreamController<List<AudioMedia>> _listController =
      StreamController<List<AudioMedia>>();
  StreamSink<List<AudioMedia>> get _albumSongsListSink => _listController.sink;
  Stream<List<AudioMedia>> get albumSongsListStream => _listController.stream;

  CurrentPlayingBloc(int albumId) {
    _fetchAlbumSongs(albumId);
  }

  Future<Null> _fetchAlbumSongs(int id) async{
    _albumSongsList = await PlatformService.fetchSongsFromAlbum(id);
    _albumSongsListSink.add(UnmodifiableListView<AudioMedia>(_albumSongsList));
  }

  @override
  void dispose() {
    _listController.close();
  }
}
