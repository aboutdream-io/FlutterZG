import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:gowedo/bloc/screen_state.dart';
import 'package:gowedo/models/notification.dart';
import 'package:gowedo/models/post.dart';
import 'package:gowedo/repositories/post_repository.dart';
import 'package:gowedo/util/gowedo.dart';
import 'package:gowedo/util/my_localization.dart';
import 'package:gowedo/util/notifications.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc_base.dart';

class FeedState extends ScreenState{
  FeedState({
    this.posts,
    StateType stateType = StateType.waiting,
    String message,
    dynamic error,
    StackTrace stackTrace,
    this.hasMorePosts,
    this.newNotification}
    ) : super(stateType: stateType, message: message, error: error, stackTrace: stackTrace);

  List<Post> posts = [];
  bool hasMorePosts = true;
  NewPostNotification newNotification;
}

class FeedBloc extends BlocBase {
  FeedBloc(this.feedRepository);

  final PostRepository feedRepository;
  MyLocalization myLocalization;
  final BehaviorSubject<FeedState> _stateController = BehaviorSubject<FeedState>.seeded(FeedState(stateType: StateType.waiting, posts: [], hasMorePosts: true));
  final BehaviorSubject<List<NewPostNotification>> _notificationsController = BehaviorSubject<List<NewPostNotification>>.seeded([]);

  StreamSubscription<String> firebaseTokenSubscription;
  StreamSubscription<Map<String, dynamic>> notificationsSubscription;

  Stream get stateStream => _stateController.stream;
  Stream get notificationStream => _notificationsController.stream;
  FeedState get _state => _stateController.value;
  List<NewPostNotification> get _notifications => _notificationsController.value;

  void getPosts({bool loadMore = false}) {
    if (_stateController?.isClosed == true || _state.stateType == StateType.loading || _state.hasMorePosts == false) {
      return;
    }
    _state.stateType = StateType.loading;
    _stateController.add(_state);

    feedRepository.getPosts(offset: loadMore ? _state.posts.length : 0, limit: 10)
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

  void refreshFeed() {
    _stateController.add(FeedState(stateType: StateType.refreshing));

    feedRepository.getPosts(offset: 0, limit: 10)
      .then((posts) {
        _stateController.add(FeedState(
            stateType: StateType.waiting,
            posts: posts,
            hasMorePosts: posts.length >= 10
        ));
    }).catchError((e) {
      _stateController.add(FeedState(stateType: StateType.error, error: e));
    });
  }

  void clearNotifications() {
    _notificationsController.add([]);
    _state.newNotification = null;
    _stateController.add(_state);
  }

  void hideShowNewPosts() {
    _state.newNotification = null;
    _stateController.add(_state);
  }

  void addNewPost(Post post) {
    _state.posts.insert(0, post);
  }

  setUpFirebaseNotifications({int count = 0}) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return;
    }

    if (!GoWeDo.notifications.hasListeners) {
      print('Getting token!');
      final String token = await GoWeDo.notifications.getFirebaseToken
          .timeout(const Duration(seconds: 2), onTimeout: () => null);

      print('Got token! $token');

      if (Platform.isIOS && token == null) {
        if (count < 3) {
          setUpFirebaseNotifications(count: ++count);
        } else {
          print('Exceeded count limit');
        }
      }

      GoWeDo.api.sendNotificationToken(token).catchError(print);
    }

    print('Listening for token change!');
    firebaseTokenSubscription = GoWeDo.notifications.onFirebaseTokenRefresh.listen((String token) {
      print('Firebase token changed: $token');
      GoWeDo.api.sendNotificationToken(token).catchError(print);
    });

    notificationsSubscription = GoWeDo.notifications.getNotificationStream.listen((Map<String, dynamic> notification) {
      print('Got notification : ${notification.toString()}');

      NewPostNotification newPostNotification = Platform.isAndroid
          ? NewPostNotification.fromJsonAndroid(notification)
          : NewPostNotification.fromJsonIos(notification);

      onNotificationReceived(newPostNotification);
    });
  }

  void onNotificationReceived(NewPostNotification notification) {
    print(notification.toString());
    if (notification.type == NotificationType.inApp) {
      _state.newNotification = notification;
      _stateController.add(_state);
    }

    _notifications.add(notification);
    _notificationsController.add(_notifications);
  }

  @override
  void dispose() {
    _stateController?.close();
    _notificationsController?.close();
    firebaseTokenSubscription?.cancel();
    notificationsSubscription?.cancel();
  }
}
