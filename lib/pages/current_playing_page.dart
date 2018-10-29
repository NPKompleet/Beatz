import 'dart:async';

import 'package:beatz/blocs/bloc_provider.dart';
import 'package:beatz/blocs/current_playing_bloc.dart';
import 'package:beatz/models/album.dart';
import 'package:beatz/models/audio_media.dart';
import 'package:beatz/widgets/needle_widget.dart';
import 'package:beatz/widgets/record_widget.dart';
import 'package:beatz/widgets/song_list_clipper.dart';
import 'package:flutter/material.dart';

class CurrentPlayingPage extends StatefulWidget {
  final Album album;

  CurrentPlayingPage({@required this.album});

  @override
  _CurrentPlayingPageState createState() => _CurrentPlayingPageState();
}

class _CurrentPlayingPageState extends State<CurrentPlayingPage>
    with TickerProviderStateMixin {
  final double iconSize = 35.0;
  final Color iconColor = Colors.deepOrangeAccent;

  AnimationController _needleAnimCtrl;
  AnimationController _recordAnimCtrl;
  OverlayState _overlayState;
  OverlayEntry _overlayEntry;
  CurrentPlayingBloc _bloc;

  @override
  initState() {
    super.initState();
    _recordAnimCtrl = AnimationController(
        duration: Duration(milliseconds: 4000), vsync: this);
    _needleAnimCtrl = AnimationController(
        duration: Duration(milliseconds: 1000),
        vsync: this,
        lowerBound: -0.2,
        upperBound: 0.0)
      ..addStatusListener((status) => _startRecordAnimation(status));
  }

  // Starts animating the Record Widget as soon as
  // the needle animation is completed.
  void _startRecordAnimation(AnimationStatus status) {
    if (status == AnimationStatus.completed) _recordAnimCtrl.repeat();
    if (status == AnimationStatus.reverse) _recordAnimCtrl.stop();
  }

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of<CurrentPlayingBloc>(context);
    return SafeArea(
      child: Material(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(
              color: Colors.pink,
            ),
            title: ValueListenableBuilder<List<String>>(
                valueListenable: _bloc.songInfo,
                builder: (_, list, __) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          list.isNotEmpty ? list.elementAt(0) : "",
                          style: TextStyle(fontSize: 18.0, color: Colors.pink),
                        ),
                        Text(
                          list.isNotEmpty ? list.elementAt(1) : "",
                          style: TextStyle(fontSize: 14.0, color: Colors.pink),
                        ),
                      ],
                    )),
            leading: IconButton(
              icon: Icon(Icons.keyboard_backspace, size: 30.0),
              onPressed: () {},
            ),
          ),
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              _buildRecordWidget(),
              _buildNeedleWidget(),
              _buildPlaybackControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordWidget() {
    return Positioned(
      top: 100.0,
      child: GestureDetector(
        child: RotationTransition(
          turns: _recordAnimCtrl,
          child: Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: Hero(
              tag: "${widget.album.id}",
              child: RecordWidget.largeImage(
                diameter: 260.0,
                albumArt: widget.album.albumArt,
              ),
            ),
          ),
        ),
        onDoubleTap: () => _showSongsList(context),
      ),
    );
  }

  Widget _buildNeedleWidget() {
    return Positioned(
      top: 50.0,
      right: 0.0,
      child: RotationTransition(
        turns: _needleAnimCtrl,
        // To make the needle swivel around the white circle
        // the alignment is placed placed at the center of the white circle
        alignment: FractionalOffset(4 / 5, 1 / 6),
        child: NeedleWidget(
          size: 130.0,
        ),
      ),
    );
  }

  Widget _buildPlaybackControls() {
    return Positioned(
      bottom: 0.0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 150.0,
        color: Colors.white,
        child: StreamBuilder<List<AudioMedia>>(
            stream: _bloc.albumSongsListStream,
            builder: (BuildContext context,
                AsyncSnapshot<List<AudioMedia>> snapshot) {
              bool data = snapshot.hasData && snapshot.data.isNotEmpty;
              return Column(
                children: <Widget>[
                  StreamBuilder<List<String>>(
                      stream: _bloc.uiStream,
                      initialData: ["0.0", "00:00", "00:00"],
                      builder: (context, snapshot) {
                        List<String> list = snapshot.data;
                        return Column(
                          children: <Widget>[
                            Slider(
                              value: double.parse(list.elementAt(0)),
                              min: 0.0,
                              max: list.elementAt(2) == "00:00" ? 0.0 : 1.0,
                              onChanged: data ? (value) => _seek(value) : null,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("${list.elementAt(1)}"),
                                  Text("${list.elementAt(2)}"),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.repeat),
                          onPressed: data ? () {} : null,
                          iconSize: iconSize,
                          color: iconColor,
                        ),
                        IconButton(
                            onPressed: data ? () {} : null,
                            icon: ImageIcon(
                              AssetImage('assets/rewind.png'),
                              size: iconSize,
                              color: iconColor,
                            )),
                        CircleAvatar(
                          backgroundColor: iconColor,
                          radius: 30.0,
                          child: ValueListenableBuilder<String>(
                              valueListenable: _bloc.playState,
                              builder: (_, value, __) {
                                return IconButton(
                                  icon: Icon(
                                    value == "play"
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    size: iconSize,
                                    color: Colors.white,
                                  ),
                                  onPressed: data ? _playSongs : null,
                                );
                              }),
                        ),
                        IconButton(
                            onPressed: data ? () {} : null,
                            icon: ImageIcon(
                              AssetImage('assets/forward.png'),
                              size: iconSize,
                              color: iconColor,
                            )),
                        IconButton(
                          icon: Icon(Icons.favorite_border),
                          onPressed: data ? () {} : null,
                          iconSize: iconSize,
                          color: iconColor,
                        ),
                      ],
                    ),
                  )
                ],
              );
            }),
      ),
    );
  }

  void _showSongsList(BuildContext context) {
    _overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
        builder: (context) => AspectRatio(
              aspectRatio: 1.0,
              child: GestureDetector(
                onHorizontalDragUpdate: (_) => _removeOverlay(),
                child: ClipPath(
                  clipper: SongListClipper(
                      screenWidth: MediaQuery.of(context).size.width,
                      padding: 8.0),
                  child: OverflowBox(
                    alignment: Alignment.center,
                    maxWidth: MediaQuery.of(context).size.width + 100.0,
                    child: Container(
                      width: MediaQuery.of(context).size.width + 100.0,
                      child: CircleAvatar(
                        child: _buildSongList(context),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    _overlayState.insert(_overlayEntry);
  }

  Widget _buildSongList(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 100.0),
      child: Center(
        child: StreamBuilder(
            stream: _bloc.albumSongsListStream,
            builder: (BuildContext context,
                AsyncSnapshot<List<AudioMedia>> snapshot) {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    AudioMedia media = snapshot.data.elementAt(index);
                    return Column(
                      children: <Widget>[
                        Divider(
                          height: 10.0,
                          color: Colors.white70,
                        ),
                        Text(
                          media.title,
                          style: TextStyle(fontSize: 20.0),
                        ),
                        index == snapshot.data.length - 1
                            ? Divider(
                                height: 10.0,
                                color: Colors.white70,
                              )
                            : Container()
                      ],
                    );
                  });
            }),
      ),
    );
  }

  void _removeOverlay() => _overlayEntry?.remove();

  Future<Null> _playSongs() async {
    _needleAnimCtrl.forward();
    // Wait for the needle animation to complete
    // before adding the song
    await Future.delayed(Duration(milliseconds: 1000));
    _bloc.startSong.add(0);
    _bloc.playState.addListener(_onPlaybackEvent);
  }

  Future<Null> _onPlaybackEvent() async {
    switch (_bloc.playState.value) {
      case "stop":
        _recordAnimCtrl.stop();
        _needleAnimCtrl.reverse();
        // Wait for the needle reverse animation to complete
        // before resetting the controller
        await Future.delayed(Duration(milliseconds: 1000));
        _needleAnimCtrl.reset();
        break;
      case "error":
        _recordAnimCtrl.stop();
        _needleAnimCtrl.reverse();
        break;
      case "pause":
        _recordAnimCtrl.stop();
        break;
    }
  }

  void _seek(double value) {
    _bloc.seekTo.add(value);
  }

  @override
  void dispose() {
    _needleAnimCtrl.dispose();
    _recordAnimCtrl.dispose();
    _removeOverlay();
    _bloc.dispose();
    super.dispose();
  }
}
