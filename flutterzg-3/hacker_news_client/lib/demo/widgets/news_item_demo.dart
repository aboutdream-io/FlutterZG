import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hacker_news_client/demo/screens/item_screen_demo.dart';
import 'package:hnpwa_client/hnpwa_client.dart';

class NewsItem extends StatelessWidget {
  NewsItem(this.item, {Key key})
    : super(key: key);

  final FeedItem item;

  @override
  Widget build(BuildContext context) {
    const TextStyle _secondaryStyle = TextStyle(
      color: Colors.black38
    );

    return Card(
      child: InkWell(

        onTap: (){
          Navigator.of(context).push(CupertinoPageRoute<void>(
            builder: (BuildContext context) => NewsItemScreen(item: item)
          ));
        },
        child: Container(
          margin: const EdgeInsets.all(12.0),
          child: Row(
            children: <Widget>[
              Container(
                height: 50.0,
                width: 50.0,
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  shape: BoxShape.circle
                ),
                child: Center(
                  child: Text('${item.points}', style: const TextStyle(color: Colors.white))
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(item.title),

                      const SizedBox(height: 20.0),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Comments: ${item.commentsCount}', style: _secondaryStyle),
                          Text('By: ${item.user}', style: _secondaryStyle),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}