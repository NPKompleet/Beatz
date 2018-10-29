import 'package:beatz/blocs/albums_page_bloc.dart';
import 'package:beatz/blocs/bloc_provider.dart';
import 'package:beatz/blocs/home_page_bloc.dart';
import 'package:beatz/blocs/playlist_page_bloc.dart';
import 'package:beatz/blocs/songs_page_bloc.dart';
import 'package:beatz/pages/albums_page.dart';
import 'package:beatz/pages/playlist_page.dart';
import 'package:beatz/pages/songs_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  HomePageBloc _bloc;
  AnimationController _controller;
  Animation<double> _heightAnimation;

  final _widgetOptions = [
    BlocProvider<AlbumsPageBloc>(
      bloc: AlbumsPageBloc(),
      child: AlbumsPage(),
    ),
    BlocProvider<SongsPageBloc>(
      bloc: SongsPageBloc(),
      child: SongsPage(),
    ),
    BlocProvider<PlaylistPageBloc>(
      bloc: PlaylistPageBloc(),
      child: PlaylistPage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: Duration(milliseconds: 4000), vsync: this);
    _heightAnimation =
        Tween<double>(begin: 0.0, end: 220.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of<HomePageBloc>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return Container(
                height: _heightAnimation.value,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepOrangeAccent,
                      Colors.purple,
                    ],
                    begin: FractionalOffset(1.2, 0.4),
                    end: FractionalOffset(-0.3, 0.8),
                    stops: [0.0, 1.0],
                  ),
                ),
                child: Center(
                  child: CircleAvatar(
                    radius: 65.0,
                    child: Image(
                      image: AssetImage("assets/headphones.png"),
                      fit: BoxFit.fill,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }),
        Expanded(
          child: StreamBuilder<int>(
              initialData: 0,
              stream: _bloc.pageIndexStream,
              builder: (context, snapshot) {
                return Scaffold(
                  body: _widgetOptions.elementAt(snapshot.data),
                  bottomNavigationBar: BottomNavigationBar(
                    currentIndex: snapshot.data,
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.album),
                        title: Text("albums"),
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.queue_music),
                        title: Text("songs"),
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.playlist_play),
                        title: Text("playlist"),
                      ),
                    ],
                    onTap: _onItemSelected,
                  ),
                );
              }),
        ),
      ],
    );
  }

  void _onItemSelected(int index) => _bloc.pageIndex.add(index);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
