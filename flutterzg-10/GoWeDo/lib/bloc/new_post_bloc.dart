import 'dart:async';
import 'dart:io';

import 'package:gowedo/bloc/screen_state.dart';
import 'package:gowedo/models/post.dart';
import 'package:gowedo/repositories/post_repository.dart';
import 'package:gowedo/util/my_localization.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc_base.dart';

class NewPostState extends ScreenState{
  NewPostState({
    this.image,
    this.post,
    StateType stateType = StateType.waiting,
    String message,
    dynamic error,
    StackTrace stackTrace}
    ) : super(stateType: stateType, message: message, error: error, stackTrace: stackTrace);

  File image;
  Post post;
}

class NewPostBloc extends BlocBase {
  NewPostBloc(this.repository, this.myLocalization);

  final PostRepository repository;
  final MyLocalization myLocalization;
  final BehaviorSubject<NewPostState> _stateController = BehaviorSubject<NewPostState>.seeded(NewPostState(stateType: StateType.waiting));
  Stream get stateStream => _stateController.stream;

  void addImage(File file) => _stateController.sink.add(NewPostState(stateType: StateType.waiting, image: file));

  void removeImage() => _stateController.sink.add((NewPostState(stateType: StateType.waiting, image: null)));

  void createPost(Post post) async {
    _stateController.add(NewPostState(
      stateType: StateType.loading,
      image: post.imageFile,
    ));

    try {
      await repository.createPost(post);
      _stateController.add(NewPostState(
          stateType: StateType.finished,
          post: post
      ));

    } catch (e) {
      _stateController.add(NewPostState(
        stateType: StateType.error,
        image: post.imageFile,
        error: e,
      ));

    }
  }

  @override
  void dispose() {
    _stateController?.close();
  }
}
