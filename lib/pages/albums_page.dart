import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:beatz/models/album.dart';
import 'package:beatz/pages/current_playing_page.dart';
import 'package:beatz/utils/platform_utils.dart';
import 'package:beatz/widgets/record_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class AlbumsPage extends StatefulWidget {
  @override
  _AlbumsPageState createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  String _fetchedAlbums = 'No albums';
  List<Album> _albumList = [];

  @override
  void initState() {
    super.initState();
    _fetchAlbums();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _albumList.length,
      itemBuilder: (context, index) {
        Album album = _albumList[index];
        return GestureDetector(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: <Widget>[
                Hero(
                  tag: "${album.id}",
                  child: RecordWidget(
                    diameter: 130.0,
                    albumArt: album.albumArt,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "${album.artist}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Color(0xFF444444)),
                        ),
                        Text(
                          "${album.album}",
                          style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold),
                        ),
                        Divider(
                          height: 5.0,
                        ),
                        Text(
                          "${album.numOfSongs} Songs",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          onTap: () => _navigateToCurrentPlaying(context, index),
        );
      },
    );
  }

  void _navigateToCurrentPlaying(BuildContext context, index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CurrentPlayingPage(
              album: _albumList[index],
            ),
      ),
    );
  }

  Future<Null> _fetchAlbums() async {
    //String albums;
    try {
      final result = await platform.invokeMethod(fetchAlbumMethod);
      //albums = 'Albums: $result';
      Iterable message = json.decode(result);
      message.forEach((e) => _albumList.add(Album.fromJson(e)));
    } on PlatformException catch (e) {
      //albums = "Failed to fetch albums: '${e.message}'.";
      print(e);
    }

    setState(() {
      //_fetchedAlbums = result;
    });

    print(_fetchedAlbums);
    print('album list: ${_albumList.length}');

    Directory appDocDir = await getExternalStorageDirectory();
    String appDocPath = appDocDir.path;

    print('appDocPath: $appDocPath');
  }
}

// 'Unsupported value: com.npkompleet.beatz.models.Album@82007b7'
// [{"album":"**Marion","albumArt":"/storage/emulated/0/Android/data/com.android.providers.media/albumthumbs/1484594943356","artist":"Scala","id":8,"numOfSongs":1},{"album":"2005-09-20 - Iron Horse Music Hall","albumArt":"/storage/emulated/0/Android/data/com.android.providers.media/albumthumbs/1484594956612","artist":"Citizen Cope","id":26,"numOfSongs":1}]
// 666394a35
