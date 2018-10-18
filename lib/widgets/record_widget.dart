import 'dart:io';

import 'package:flutter/material.dart';

class RecordWidget extends StatelessWidget {
  /// the length of the diameter of the record
  final double diameter;
  final String albumArt;
  final File file;
  final bool large;

  RecordWidget({@required this.diameter, @required this.albumArt})
      : file = File('$albumArt'),
        large = false;

  RecordWidget.largeImage({@required this.diameter, @required this.albumArt})
      : file = File('$albumArt'),
        large = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      child: Stack(
        children: [
          Image(
            image: large
                ? AssetImage('assets/record2.png')
                : AssetImage('assets/record2.png'),
            width: diameter,
            height: diameter,
            fit: BoxFit.fill,
          ),
          // Check that the album art is not null
          // before building it
          file.path == "null"
              ? Center()
              : Center(
                  child: Container(
                    width: diameter / 2.5,
                    height: diameter / 2.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: FileImage(
                          file,
                        ),
                      ),
                    ),
                  ),
                ),
          Center(
            child: Container(
              width: diameter / 20,
              height: diameter / 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
