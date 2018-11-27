import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hacker_news_client/final/widgets/comment_item.dart';
import 'package:hnpwa_client/hnpwa_client.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

enum SelectedTab{
  comments, link
}

class SingleStoryScreen extends StatefulWidget {
  const SingleStoryScreen({Key key, this.itemId}) : super(key: key);

  final int itemId;

  @override _SingleStoryState createState() => _SingleStoryState();
}

class _SingleStoryState extends State<SingleStoryScreen> with TickerProviderStateMixin{
  InAppWebViewController webView;
  double progress = 0;
  String _currentUrl;

  SelectedTab _selectedTab;

  @override
  void initState() {
    super.initState();

    _selectedTab = SelectedTab.comments;
  }

  @override
  Widget build(BuildContext context) {
    final HnpwaClient _client = HnpwaClient();

    return FutureBuilder<Item>(
      future: _client.item(widget.itemId),
      builder: (BuildContext context, AsyncSnapshot<Item> snapshot){
        if(snapshot.hasData){
          _currentUrl ??= snapshot.data.url;

          return Scaffold(
            appBar: AppBar(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 1.0, top: 4.0),
                    child: Text(snapshot.data.title,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.title.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white
                      )
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 1.0, bottom: 4.0),
                    child: Text(_currentUrl,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.title.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70
                      )
                    ),
                  ),
                ],
              ),
            ),
            body: _showComments(snapshot.data),//_showWebView(snapshot.data),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedTab.index,
              onTap: (int index){
                setState(() {
                  _selectedTab = SelectedTab.values[index];
                });
              },
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.comment), title: Text('Comments')),
                BottomNavigationBarItem(icon: Icon(Icons.web), title: Text('Link')),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Loading...'),
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildLinkStory(BuildContext context, Item storyItem){
    print('Loading: ${storyItem.url}');

    return AnimatedCrossFade(
      crossFadeState: _selectedTab == SelectedTab.link ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: Duration(milliseconds: 250),
      firstChild: _showWebView(storyItem),
      secondChild: _showComments(storyItem),
    );
  }

  Widget _showWebView(Item storyItem){
    if(Platform.isIOS){
      void _openWebViewIos() async {
        if(InAppBrowser().isOpened()){
          await InAppBrowser().close();
        }

        await InAppBrowser().open(url: storyItem.url, options: <String, dynamic>{
          'toolbarTopBackgroundColor': '#${Theme.of(context).accentColor.value.toRadixString(16)}',
          'closeButtonCaption': 'X',
          'closeButtonColor': '#FFFFFF'
        });
      }

      return Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.not_interested, size: 128.0, color: Colors.grey.shade400),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('iOS doesn\'t support inline web view yet!',
                  style: Theme.of(context).textTheme.title.copyWith(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                    fontSize: 18.0
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${storyItem.url}',
                  textAlign: TextAlign.center,
                ),
              ),
              CupertinoButton(
                onPressed: _openWebViewIos,
                child: Text('Open in webview'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      child: InAppWebView(
        initialUrl: storyItem.url,
        onWebViewCreated: (InAppWebViewController controller){
          webView = controller;
        },
        onProgressChanged: (InAppWebViewController controller, int progress){
          setState(() {
            this.progress = progress/100;
          });
        },
        onLoadStart: (InAppWebViewController controller, String url){
          setState(() {
            _currentUrl = url;
          });
        },
      ),
    );
  }

  Widget _showComments(Item storyItem){
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: _buildCommentItems(storyItem),
        ),
      ),
    );
  }

  List<Widget> _buildCommentItems(Item storyItem){
    final List<Widget> _commentWidgets = <Widget>[];

    void _buildComments(Item i, {int depth = 0}){
      _commentWidgets.add(CommentItem(comment: i, depth: depth));

      if(i.comments.isNotEmpty){
        i.comments.forEach((Item i) => _buildComments(i, depth: ++depth));
      }
    }

    storyItem.comments.forEach(_buildComments);

    return _commentWidgets;
  }
}