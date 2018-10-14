import 'package:flutter/material.dart';

class SongListClipper extends CustomClipper<Path> {
  double screenWidth;
  double padding;

  SongListClipper({this.screenWidth, this.padding});

  /// Draw a square clip shape
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.moveTo(size.width / 2 - screenWidth / 2 + padding, 0.0);
    path.lineTo(size.width / 2 - screenWidth / 2 + padding, size.height);
    path.lineTo(size.width / 2 + screenWidth / 2 - padding, size.height);
    path.lineTo(size.width / 2 + screenWidth / 2 - padding, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
