import 'dart:math';

import 'package:flutter/material.dart';

class HeroScreen extends StatelessWidget {
  HeroScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Hero animation'),
      ),
      body: Container(
        child: Container(
          child: Hero(
            tag: 'hero_1',
            child: Container(
              height: 100.0,
              width: 100.0,
              decoration: BoxDecoration(
                color: Colors.primaries[Random().nextInt(Colors.primaries.length - 1)].withOpacity(0.3),
              ),
              child: FlutterLogo(),
            ),
          ),
        ),
      ),
    );
  }
}
