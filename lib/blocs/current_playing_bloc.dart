import 'dart:async';
import 'dart:collection';

import 'package:beatz/blocs/bloc_provider.dart';
import 'package:beatz/models/audio_media.dart';
import 'package:beatz/services/platform_service.dart';
import 'package:beatz/utils/TimeUtil.dart';
import 'package:flutter/foundation.dart';

class CurrentPlayingBloc extends BlocBase {
  List<AudioMedia> _albumSongsList = [];
  int _songIndex = 0;
  Timer _timer;
  int _duration = 0;
  String _durationString;
  int _position = 0;

  /// Stream to handle displaying songs
  StreamController<List<AudioMedia>> _listController =
      StreamController<List<AudioMedia>>();
  StreamSink<List<AudioMedia>> get _albumSongsListSink => _listController.sink;
  Stream<List<AudioMedia>> get albumSongsListStream => _listController.stream;

  /// Stream to handle playing songs
  StreamController _playController = StreamController();
  StreamSink get startSong => _playController.sink;
  Stream get _playSong => _playController.stream;

  /// Stream to handle updating slider
  StreamController<List<String>> _uiController =
      StreamController<List<String>>();
  StreamSink<List<String>> get _uiSink => _uiController.sink;
  Stream<List<String>> get uiStream => _uiController.stream;

  CurrentPlayingBloc(int albumId) {
    _fetchAlbumSongs(albumId);
    _playSong.listen(_startPlaying);
  }

  Future<Null> _fetchAlbumSongs(int id) async {
    _albumSongsList = await PlatformService.fetchSongsFromAlbum(id);
    _albumSongsListSink.add(UnmodifiableListView<AudioMedia>(_albumSongsList));
    _duration = _albumSongsList[0].duration;
    _durationString = await compute(TimeUtil.convertTimeToString, _duration);
  }

  Future<Null> _startPlaying(data) async {
    print('playback started');
    String result = await PlatformService.playSong(_albumSongsList[0].uri);
    if (result == "success") {
      print("was result");
      _timer = Timer.periodic(Duration(milliseconds: 500), _getPosition);
    }
  }

  Future<Null> _getPosition(Timer timer) async {
    final List<String> list = [];
    _position = await PlatformService.getPlaybackPosition();
    list.add((_position / _duration).toString());
    list.add(await compute(TimeUtil.convertTimeToString, _position));
    list.add(_durationString);
    _uiSink.add(list);
  }

  @override
  void dispose() {
    _listController.close();
    _playController.close();
    _uiController.close();
    _timer?.cancel();
  }
}
