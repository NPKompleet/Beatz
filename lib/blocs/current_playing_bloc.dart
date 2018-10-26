import 'dart:async';
import 'dart:collection';

import 'package:beatz/blocs/bloc_provider.dart';
import 'package:beatz/models/audio_media.dart';
import 'package:beatz/services/platform_service.dart';
import 'package:beatz/utils/time_util.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

class CurrentPlayingBloc extends BlocBase {
  List<AudioMedia> _albumSongsList = [];
  int _songIndex = 0;
  int _duration = 0;
  String _durationString;
  int _position = 0;
  final playState = ValueNotifier<String>("");
  final songInfo = ValueNotifier<List<String>>([]);

  // Stream to handle displaying songs
  BehaviorSubject<List<AudioMedia>> _listController =
      BehaviorSubject<List<AudioMedia>>();
  StreamSink<List<AudioMedia>> get _albumSongsListSink => _listController.sink;
  Stream<List<AudioMedia>> get albumSongsListStream => _listController.stream;

  // Stream to handle playing songs
  StreamController _playController = StreamController();
  StreamSink get startSong => _playController.sink;
  Stream get _playSong => _playController.stream;

  // Stream to handle updating slider
  StreamController<List<String>> _uiController =
      StreamController<List<String>>();
  StreamSink<List<String>> get _uiSink => _uiController.sink;
  Stream<List<String>> get uiStream => _uiController.stream;

  CurrentPlayingBloc(int albumId) {
    _fetchAlbumSongs(albumId);
    _playSong.listen(_startPlaying);
    PlatformService.stopNotifier = ValueNotifier("");
  }

  Future<Null> _fetchAlbumSongs(int id) async {
    _albumSongsList = await PlatformService.fetchSongsFromAlbum(id);
    _albumSongsListSink.add(UnmodifiableListView<AudioMedia>(_albumSongsList));
    songInfo.value = [
      _albumSongsList[_songIndex].title,
      _albumSongsList[_songIndex].artist
    ];
    _duration = _albumSongsList[_songIndex].duration;
    _durationString = await compute(TimeUtil.convertTimeToString, _duration);
  }

  Future<Null> _startPlaying(data) async {
    print('playback started');
    playState.value = "play";
    PlatformService.stopNotifier.addListener(_stopAnim);
    PlatformService.positionNotifier.addListener(_getPosition);
    PlatformService.playSong(_albumSongsList[_songIndex].uri);
  }

  void _getPosition() {
    final List<String> list = [];
    _position = PlatformService.positionNotifier.value;
    list.add((_position / _duration).toString());
    list.add(TimeUtil.convertTimeToString(_position));
    list.add(_durationString);
    _uiSink.add(list);
  }

  void _stopAnim() {
    playState.value = "stop";
  }

  @override
  void dispose() {
    _listController.close();
    _playController.close();
    _uiController.close();
    PlatformService.stopNotifier.dispose();
    playState.dispose();
    songInfo.dispose();
  }
}
