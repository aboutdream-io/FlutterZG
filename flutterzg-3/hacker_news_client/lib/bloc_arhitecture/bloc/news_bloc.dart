import 'dart:async';

import 'package:hacker_news_client/bloc_arhitecture/bloc/news_repository.dart';
import 'package:hnpwa_client/hnpwa_client.dart';
import 'package:rxdart/rxdart.dart';

class NewsBloc{
  NewsBloc(this._repository) :
    _newsFeed = BehaviorSubject<List<FeedItem>>(),
    _newsItem = BehaviorSubject<Item>();

  final NewsRepository _repository;

  final BehaviorSubject<List<FeedItem>> _newsFeed;
  final BehaviorSubject<Item> _newsItem;

  Stream<List<FeedItem>> get newsFeed => _newsFeed.stream;
  Stream<Item> get newsDetails => _newsItem.stream;

  bool get hasNextPage => _repository.hasNext;

  void nextPage(){
    _repository.nextPage();
    getNews();
  }

  void getNews({int page = 0}) async {
    final List<FeedItem> _items = await _repository.getNews(page: page);
    _newsFeed.add(_items);
  }

  void getNewsItem({int newsId}) async {
    final Item i = await _repository.getNewsById(newsId: newsId);
    _newsItem.add(i);
  }

  void dispose(){
    _newsFeed.close();
    _newsItem.close();
  }
}