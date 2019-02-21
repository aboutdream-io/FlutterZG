import 'dart:async';

import 'package:hnpwa_client/hnpwa_client.dart';

class NewsRepository{
  final HnpwaClient _client = HnpwaClient();

  bool _hasNextPage = true;
  final Map<int, List<FeedItem>> _feedItems = <int, List<FeedItem>>{};

  int _page = 1;
  bool get hasNext => _hasNextPage;

  void nextPage() => _page++;
  void previousPage() => _page--;

  Future<List<FeedItem>> getNews({int page = 1}) async {
    if(page == 0){
      page = _page;
    }

    final Feed f = await _client.news(page: page);

    _hasNextPage = f.hasNextPage;

    _feedItems.addAll(<int, List<FeedItem>>{
      page: f.items
    });

    return _feedItems.values.fold(
      <FeedItem>[], (List<FeedItem> feed, List<FeedItem> items)=> feed..addAll(items)
    ).toList();
  }

  Future<Item> getNewsById({int newsId}) async {
    final Item i = await _client.item(newsId);
    return i;
  }
}