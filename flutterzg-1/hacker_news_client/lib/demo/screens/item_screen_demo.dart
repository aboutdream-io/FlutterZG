import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:hacker_news_client/demo/widgets/comment_item_demo.dart';
import 'package:hnpwa_client/hnpwa_client.dart';

enum AvailableTabs{
  comments, link
}

class NewsItemScreen extends StatefulWidget {
  NewsItemScreen({Key key, this.item}) : super(key: key);

  final FeedItem item;

  @override
  _NewsItemScreenState createState() => new _NewsItemScreenState();
}

class _NewsItemScreenState extends State<NewsItemScreen> {
  AvailableTabs _currentTab;

  @override
  void initState() {
    super.initState();

    _currentTab = AvailableTabs.comments;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Item>(
      future: HnpwaClient().item(widget.item.id),
      builder: (BuildContext context, AsyncSnapshot<Item> snapshot){
        if(snapshot.hasData){
          return _buildContent(snapshot.data);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Loading...'),
          ),
          body: Center(child: CircularProgressIndicator(),),
        );
      },
    );
  }

  Widget _buildContent(Item item){
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(widget.item.title),
            Text(widget.item.url,
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.white54
              ),
            ),
          ],
        ),
      ),
      body: AnimatedCrossFade(
        firstChild: ListView(
          children: _getComments(item),
        ),
        secondChild: _getWebView(),
        duration: Duration(milliseconds: 250),
        crossFadeState: CrossFadeState.values[_currentTab.index],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab.index,
        onTap: (int value){
          setState(() {
            _currentTab = AvailableTabs.values[value];
          });
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.comment), title: Text('Comments')),
          BottomNavigationBarItem(icon: Icon(Icons.link), title: Text('Links')),
        ],
      ),
    );
  }

  Widget _getWebView(){
    if(Platform.isIOS){
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Not supported!'),
            OutlineButton(
              child: const Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Open in external window'),
              ),
              onPressed: (){
                InAppBrowser().open(url: widget.item.url, options: <String, dynamic>{
                  'toolbarTopBackgroundColor': Theme.of(context).accentColor.value.toRadixString(16)
                });
              },
            )
          ],
        ),
      );
    }

    return InAppWebView(
      initialUrl: widget.item.url,
    );
  }

  List<Widget> _getComments(Item item){
    List<Widget> _commentWidgets = <Widget>[];

    void _generateComment(Item i, {int depth = 0}){
      _commentWidgets.add(CommentItem(comment: i, depth: depth));

      if(i.comments.isNotEmpty){
        i.comments.forEach((Item i) => _generateComment(i, depth: ++depth));
      }
    }

    item.comments.forEach(_generateComment);

    return _commentWidgets;
  }
}
