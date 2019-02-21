import 'package:flutter/material.dart';
import 'package:hacker_news_client/bloc_arhitecture/bloc/news_bloc.dart';
import 'package:hacker_news_client/bloc_arhitecture/screens/single_item_screen.dart';
import 'package:hnpwa_client/hnpwa_client.dart';

class NewsItem extends StatelessWidget {
  const NewsItem({Key key, this.item}) : super(key: key);

  final FeedItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: (){
          Navigator.of(context).push<Null>(MaterialPageRoute<Null>(
            builder: (BuildContext context)=> SingleStoryScreen(itemId: item.id)
          ));
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.all(8.0),
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).accentColor
                ),
                child: Center(child: Text('${item.points}',
                  style: Theme.of(context).textTheme.title.copyWith(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w900
                  ),
                )),
              ),
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(right: 12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(item.title),
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Comments: ${item.commentsCount}',
                            style: Theme.of(context).textTheme.title.copyWith(
                              color: Colors.black38,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400
                            ),
                          ),
                          Text('By: ${item.user}',
                            style: Theme.of(context).textTheme.title.copyWith(
                              color: Colors.black38,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
