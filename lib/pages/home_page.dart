import 'package:beatz/blocs/albums_page_bloc.dart';
import 'package:beatz/blocs/bloc_provider.dart';
import 'package:beatz/pages/albums_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _heightAnimation;

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
          child: Scaffold(
            body: BlocProvider<AlbumsPageBloc>(
              bloc: AlbumsPageBloc(),
              child: AlbumsPage(),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 0,
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
            ),
          ),
        ),
      ],
    );
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0.0, size.height - 20);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 20.0);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 20);
    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
