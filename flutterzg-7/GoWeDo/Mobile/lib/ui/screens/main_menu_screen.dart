import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({Key key}): super(key: key);

  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('main screen'),
      ),
    );
  }
}
