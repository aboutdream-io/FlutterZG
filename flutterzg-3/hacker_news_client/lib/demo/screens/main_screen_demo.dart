import 'package:flutter/material.dart';
import 'package:hacker_news_client/demo/widgets/news_item_demo.dart';
import 'package:hnpwa_client/hnpwa_client.dart';

class MainScreenDemo extends StatefulWidget {
  MainScreenDemo({Key key}) : super(key: key);

  @override
  _MainScreenDemoState createState() => new _MainScreenDemoState();
}

class _MainScreenDemoState extends State<MainScreenDemo> {
  final HnpwaClient _client = HnpwaClient();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('HN Client'),
      ),
      body: FutureBuilder<Feed>(
        future: _client.news(),
        builder: (BuildContext context,
          AsyncSnapshot<Feed> snapshot){

          if(snapshot.hasData){
            return ListView(
              children: snapshot.data.items.map(
                  (FeedItem fi) => NewsItem(fi),
              ).toList(),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
