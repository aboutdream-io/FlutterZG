import 'package:flutter/material.dart';
import 'package:hacker_news_client/final/screens/main_screen.dart';
import 'package:hacker_news_client/demo/screens/main_screen_demo.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HN Client',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: MainScreenDemo(),
    );
  }
}