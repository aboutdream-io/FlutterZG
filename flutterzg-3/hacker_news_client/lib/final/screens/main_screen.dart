import 'package:flutter/material.dart';
import 'package:hacker_news_client/final/widgets/news_item.dart';
import 'package:hnpwa_client/hnpwa_client.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key key}) : super(key: key);

  @override
  _MainScreenState createState() => new _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final HnpwaClient _client = HnpwaClient();
  final Map<int, List<FeedItem>> _allFeed = <int, List<FeedItem>>{};

  int _page = 1;
  bool _hasNextPage = true;
  ScrollController _controller;

  @override
  void initState(){
    super.initState();

    _controller = ScrollController();
    _controller.addListener((){
      final double _maxScroll = _controller.position.maxScrollExtent;
      final double _currentScroll = _controller.position.pixels;
      const double _delta = 200.0;

      if(_maxScroll - _currentScroll <= _delta && _hasNextPage){
        setState(() {
          ++_page;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('HN Client'),
      ),
      body: FutureBuilder<Feed>(
        future: _client.news(page: _page),
        builder: (BuildContext context, AsyncSnapshot<Feed> snapshot){
          if(!snapshot.hasData){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          _hasNextPage = snapshot.data.hasNextPage;

          _allFeed.addAll(<int, List<FeedItem>>{_page: snapshot.data.items});

          final List<FeedItem> _feed = _allFeed.values.fold(
            <FeedItem>[], (List<FeedItem> feed, List<FeedItem> f)=> feed..addAll(f));

          return SingleChildScrollView(
            controller: _controller,
            child: Container(
              child: Column(
                children: _feed.map((FeedItem i) => NewsItem(item: i)).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

