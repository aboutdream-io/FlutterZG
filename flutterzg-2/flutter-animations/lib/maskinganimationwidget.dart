import 'package:flutter/material.dart';

class MaskingAnimationWidget extends StatefulWidget {
  @override
  MaskingAnimationWidgetState createState() =>
      MaskingAnimationWidgetState();
}

class MaskingAnimationWidgetState extends State<MaskingAnimationWidget>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> transitionTween;
  Animation<BorderRadius> borderRadius;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this)
      ..addStatusListener((AnimationStatus status){
        if(status == AnimationStatus.completed){
          _controller.reverse();
        }
    });

    transitionTween = Tween<double>(
      begin: 0.0,
      end: 200.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    );
    borderRadius = BorderRadiusTween(
      begin: BorderRadius.circular(75.0),
      end: BorderRadius.circular(0.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward(from: 0.0);

    return Container(
      height: 200.0,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget child) {
          return Scaffold(
              body: new Center(
                  child: new Stack(
                    children: <Widget>[
                      new Center(
                          child: Container(
                            width: 200.0,
                            height: 200.0,
                            color: Colors.black12,
                          )),
                      new Center(
                          child: Container(
                            alignment: Alignment.bottomCenter,
                            width: transitionTween.value,
                            height: transitionTween.value,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.5),
                              borderRadius: borderRadius.value,
                            ),
                          )),
                    ],
                  )));
        },
      ),
    );
  }
}