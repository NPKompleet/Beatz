import 'package:flutter/material.dart';

class NeedleWidget extends StatelessWidget {
  final double size;

  NeedleWidget({@required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image(
        image: AssetImage('assets/needle.png'),
        width: size,
        height: size,
      ),
    );
  }
}
