import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ParentingAnimationWidget extends StatefulWidget {
  @override
  ParentingAnimationWidgetState createState() => ParentingAnimationWidgetState();
}

class ParentingAnimationWidgetState extends State<ParentingAnimationWidget> with TickerProviderStateMixin {
  Animation growingAnimation;
  Animation animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    growingAnimation =
        Tween(begin: 10.0, end: 66.0).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));
    animation = Tween(begin: -0.25, end: 0.0).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    ))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.forward();
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    controller.reverse(from: 66.0);
    return Container(
      height: 200.0,
      child: AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, Widget child) {
            return new Scaffold(
                body: new Container(
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                  Container(
                    height: growingAnimation.value,
                    width: (growingAnimation.value / 66) * 200,
                    color: Colors.black12,
                  ),
                  Container(
                    height: max(growingAnimation.value, 33.0),
                    width: max((growingAnimation.value / 66) * 200, 100.0),
                    color: Colors.black12,
                  ),
                  new Center(
                      child: new Container(
                    child: Container(
                      width: 200.0,
                      height: 66.0,
                      color: Colors.black12,
                    ),
                  )),
                ])));
          }),
    );
  }
}
