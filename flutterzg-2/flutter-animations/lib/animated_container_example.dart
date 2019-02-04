import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedContainerWidget extends StatefulWidget {
  AnimatedContainerWidget({Key key}) : super(key: key);

  @override
  _AnimatedContainerWidgetState createState() => new _AnimatedContainerWidgetState();
}

class _AnimatedContainerWidgetState extends State<AnimatedContainerWidget> {
  double _containerHeight = 200.0;
  double _containerWidth = 200.0;

  Gradient _gradient = LinearGradient(colors: <Color>[Colors.black12, Colors.black12]);

  double _borderRadius = 0.0;
  Border _border = Border.all(color: Colors.transparent);

  void _changeStuff(){
    setState(() {
      _gradient = RadialGradient(
        focalRadius: 2.0,
        radius: 0.4,
        colors: <Color>[
          Colors.green,
          Colors.red,
        ]
      );

      _containerHeight = 100.0;
      _borderRadius = _containerHeight;
      _containerWidth = _containerHeight;

      _border = Border.all(
        width: 14.0,
        color: Colors.blue
      );
    });
  }

  void _resetStuff(){
    setState(() {
      _containerHeight = 200.0;
      _containerWidth = 200.0;

      _gradient = LinearGradient(colors: <Color>[Colors.black12, Colors.black12]);

      _borderRadius = 0.0;
      _border = Border.all(color: Colors.transparent);
    });
  }

  @override
  void initState() {
    super.initState();

    Future<void>.delayed(Duration(milliseconds: 50), _changeStuff);
    Future<void>.delayed(Duration(milliseconds: 1550), _resetStuff);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.0,
      child: Scaffold(
        body: Center(
          child: AnimatedContainer(
            duration: Duration(seconds: 1),
            height: _containerHeight,
            width: _containerWidth,
            decoration: BoxDecoration(
              gradient: _gradient,
              borderRadius: BorderRadius.circular(_borderRadius),
              border: _border,
            ),
          ),
        ),
      ),
    );
  }
}
