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
  static const double iconSize = 35.0;
  static const Color iconColor = Colors.deepOrangeAccent;

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
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: Container(
          color: Colors.white,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              _buildRecordWidget(),
              _buildNeedleWidget(),
              _buildPlaybackControls(),
              _buildBackButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordWidget() {
    return Positioned(
      top: 150.0,
      child: GestureDetector(
        child: RotationTransition(
          turns: _recordAnimCtrl,
          child: Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: Hero(
              tag: "${widget.album.id}",
              child: RecordWidget(
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
      top: 100.0,
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
    _bloc = BlocProvider.of<CurrentPlayingBloc>(context);
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
//                        bool slidData = snapshot.hasData;
                        List<String> list = snapshot.data;
                        return Column(
                          children: <Widget>[
                            Slider(
                              value: double.parse(list.elementAt(0)),
                              min: 0.0,
                              max: list.elementAt(2) != "00:00" ? 1.0 : 0.0,
                              onChanged: data ? (value) {} : null,
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
                        ValueListenableBuilder<String>(
                            valueListenable: _bloc.playState,
                            builder: (_, value, __) {
                              return CircleAvatar(
                                backgroundColor: iconColor,
                                radius: 30.0,
                                child: IconButton(
                                  icon: Icon(
                                    value == "play"
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    size: iconSize,
                                    color: Colors.white,
                                  ),
                                  onPressed: data ? _playSongs : null,
                                ),
                              );
                            }),
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

  Widget _buildBackButton() {
    return Positioned(
      left: 5.0,
      top: 5.0,
      child: IconButton(
        icon: Icon(
          Icons.keyboard_backspace,
          size: 30.0,
          color: Colors.pinkAccent,
        ),
        onPressed: () {},
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
                          media.displayName,
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ],
                    );
                  });
            }),
      ),
    );
  }

  void _removeOverlay() => _overlayEntry?.remove();

  void _playSongs() {
    _needleAnimCtrl.forward();
    _bloc.startSong.add(0);
  }

  @override
  void dispose() {
    _needleAnimCtrl.dispose();
    _recordAnimCtrl.dispose();
    _removeOverlay();
    super.dispose();
  }
}
