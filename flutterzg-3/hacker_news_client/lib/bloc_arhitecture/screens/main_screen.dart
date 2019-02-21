import 'package:flutter/material.dart';
import 'package:hacker_news_client/bloc_arhitecture/bloc/news_bloc.dart';
import 'package:hacker_news_client/bloc_arhitecture/bloc/news_bloc_provider.dart';
import 'package:hacker_news_client/bloc_arhitecture/bloc/news_repository.dart';
import 'package:hacker_news_client/bloc_arhitecture/widgets/news_item.dart';
import 'package:hnpwa_client/hnpwa_client.dart';

class MainScreenBloc extends StatefulWidget {
  MainScreenBloc({Key key}) : super(key: key);

  @override
  _MainScreenBlocState createState() => new _MainScreenBlocState();
}

class _MainScreenBlocState extends State<MainScreenBloc> {
  NewsBloc _bloc;
  ScrollController _controller;

  @override
  void initState(){
    super.initState();

    _controller = ScrollController();
    _controller.addListener((){
      final double _maxScroll = _controller.position.maxScrollExtent;
      final double _currentScroll = _controller.position.pixels;
      const double _delta = 200.0;

      if(_maxScroll - _currentScroll <= _delta && _bloc.hasNextPage){
        _bloc.nextPage();
      }
    });
  }

  @override
  Widget build(BuildContext context){
    if(_bloc == null){
      _bloc = NewsBlocProvider.of(context);
      _bloc.getNews();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('HN Client'),
      ),
      body: StreamBuilder<List<FeedItem>>(
        stream: _bloc.newsFeed,
        builder: (BuildContext context, AsyncSnapshot<List<FeedItem>> snapshot){
          if(!snapshot.hasData){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            controller: _controller,
            child: Container(
              child: Column(
                children: snapshot.data.map((FeedItem i) => NewsItem(item: i)).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

