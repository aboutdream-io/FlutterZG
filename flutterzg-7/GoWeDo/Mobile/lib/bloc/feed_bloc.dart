import 'dart:async';

import 'package:gowedo/bloc/screen_state.dart';
import 'package:gowedo/models/post.dart';
import 'package:gowedo/repositories/post_repository.dart';
import 'package:gowedo/util/my_localization.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc_provider.dart';

class FeedState extends ScreenState{
  FeedState({
    this.posts,
    StateType stateType = StateType.waiting,
    String message,
    dynamic error,
    StackTrace stackTrace,
    this.hasMorePosts}
    ) : super(stateType: stateType, message: message, error: error, stackTrace: stackTrace);

  List<Post> posts = [];
  bool hasMorePosts = true;
}

class FeedBloc extends BlocBase {
  static final FeedBloc _bloc = FeedBloc._internal();
  factory FeedBloc(MyLocalization myLocalization, PostRepository postRepository){
    if (_bloc._repository == null){
      _bloc._myLocalization = myLocalization;
      _bloc._repository = postRepository;
      _bloc._stateController = BehaviorSubject<FeedState>.seeded(FeedState(stateType: StateType.waiting, posts: [], hasMorePosts: true));
    }
    return _bloc;
  }
  FeedBloc._internal();

  PostRepository _repository;
  MyLocalization _myLocalization;
  BehaviorSubject<FeedState> _stateController;

  Stream get stateStream => _stateController.stream;
  FeedState get _state => _stateController.value;

  void getPosts({bool loadMore = false}) {
    if (_stateController?.isClosed == true || _state.stateType == StateType.loading || _state.hasMorePosts == false) {
      return;
    }
    _state.stateType = StateType.loading;
    _repository.getPosts(offset: loadMore ? _state.posts.length : 0, limit: 10)
      .then((posts) {
        if (!loadMore) {
          _state.posts.clear();
        }
        _state.posts.addAll(posts);
        if (!_stateController.isClosed) {
          _stateController.add(FeedState(
            stateType: StateType.waiting,
            posts: _state.posts,
            hasMorePosts: posts.length >= 10
          ));
        }
    }).catchError((e) {
      print(e.toString());
      if (!_stateController.isClosed) {
        _stateController.add(FeedState(
          error: e,
          stateType: StateType.error,
          posts: _state.posts,
        ));
      }
    });
  }

  void addNewPost(Post post) {
    _state.posts.insert(0, post);
  }

  @override
  void dispose() {
    _stateController?.close();
  }
}
