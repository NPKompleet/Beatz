import 'dart:async';
import 'dart:convert';

import 'package:beatz/models/album.dart';
import 'package:beatz/models/audio_media.dart';
import 'package:beatz/utils/platform_utils.dart';
import 'package:beatz/widgets/needle_widget.dart';
import 'package:beatz/widgets/record_widget.dart';
import 'package:beatz/widgets/song_list_clipper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CurrentPlayingPage extends StatefulWidget {
  final Album album;

  CurrentPlayingPage({@required this.album});

  @override
  _CurrentPlayingPageState createState() => _CurrentPlayingPageState();
}

class _CurrentPlayingPageState extends State<CurrentPlayingPage>
    with SingleTickerProviderStateMixin {
  static const double iconSize = 35.0;
  static const Color iconColor = Colors.deepOrangeAccent;

  AnimationController _animationController;
  List<AudioMedia> _albumSongsList = [];
  OverlayState _overlayState;
  OverlayEntry _overlayEntry;

  @override
  initState() {
    super.initState();
    _fetchSongsFromAlbum();
    _animationController = AnimationController(
        duration: Duration(milliseconds: 1500),
        vsync: this,
        lowerBound: -0.2,
        upperBound: 0.0)
      ..forward();
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
        onDoubleTap: () => _showSongsList(context),
      ),
    );
  }

  Widget _buildNeedleWidget() {
    return Positioned(
      top: 100.0,
      right: 0.0,
      child: RotationTransition(
        turns: _animationController,
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
        child: Column(
          children: <Widget>[
            Slider(
              value: 0.0,
              onChanged: (_) {},
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("0:00"),
                  Text("4:32"),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.repeat),
                    onPressed: () {},
                    iconSize: iconSize,
                    color: iconColor,
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: ImageIcon(
                        AssetImage('assets/rewind.png'),
                        size: iconSize,
                        color: iconColor,
                      )),
                  CircleAvatar(
                    backgroundColor: iconColor,
                    radius: 30.0,
                    child: Center(
                      child: IconButton(
                        icon: Icon(
                          Icons.play_arrow,
                          size: iconSize,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: ImageIcon(
                        AssetImage('assets/forward.png'),
                        size: iconSize,
                        color: iconColor,
                      )),
                  IconButton(
                    icon: Icon(Icons.favorite_border),
                    onPressed: () {},
                    iconSize: iconSize,
                    color: iconColor,
                  ),
                ],
              ),
            )
          ],
        ),
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

  Future<Null> _fetchSongsFromAlbum() async {
    Map<String, int> albumInfo = {"albumId": widget.album.id};
    print("AlbumID: ${widget.album.id}");
    try {
      final result =
          await platform.invokeMethod(fetchSongsFromAlbumMethod, albumInfo);
      print("Songs: $result");
      Iterable message = json.decode(result);
      message.forEach((e) => _albumSongsList.add(AudioMedia.fromJson(e)));
    } on PlatformException catch (e) {
      print(e);
    }

    // Refresh
    setState(() {});
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
//      color: Colors.green,
      height: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 100.0),
      child: Center(
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: _albumSongsList.length,
            itemBuilder: (context, index) {
              AudioMedia media = _albumSongsList[index];
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
            }),
      ),
    );
  }

  void _removeOverlay() => _overlayEntry.remove();

  @override
  void dispose() {
    _animationController.dispose();
    _overlayEntry.remove();
    super.dispose();
  }
}
