import 'package:beatz/blocs/albums_page_bloc.dart';
import 'package:beatz/blocs/bloc_provider.dart';
import 'package:beatz/blocs/current_album_bloc.dart';
import 'package:beatz/models/album.dart';
import 'package:beatz/pages/current_album_page.dart';
import 'package:beatz/widgets/record_widget.dart';
import 'package:flutter/material.dart';

class AlbumsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AlbumsPageBloc bloc = BlocProvider.of<AlbumsPageBloc>(context);
    return StreamBuilder<List<Album>>(
      stream: bloc.albumListStream,
      builder: (BuildContext context, AsyncSnapshot<List<Album>> snapshot) {
        if (!snapshot.hasData)
          return Container(
            child: Center(child: Text("Loading Albums....")),
          );
        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            Album album = snapshot.data.elementAt(index);
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
              onTap: () => _navigateToCurrentPlaying(context, album),
            );
          },
        );
      },
    );
  }

  void _navigateToCurrentPlaying(BuildContext context, Album album) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return BlocProvider<CurrentAlbumBloc>(
          bloc: CurrentAlbumBloc(album.id),
          child: CurrentAlbumPage(
            album: album,
          ),
        );
      }),
    );
  }
}
