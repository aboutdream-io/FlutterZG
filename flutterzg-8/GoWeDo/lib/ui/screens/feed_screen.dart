import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gowedo/bloc/feed_bloc.dart';
import 'package:gowedo/bloc/screen_state.dart';
import 'package:gowedo/models/post.dart';
import 'package:gowedo/ui/widgets/error_with_refresh_button.dart';
import 'package:gowedo/ui/widgets/notifications_indicator.dart';
import 'package:gowedo/util/dependency_injection.dart';
import 'package:gowedo/util/my_colors.dart';
import 'package:gowedo/util/my_images.dart';
import 'package:gowedo/util/my_localization.dart';
import 'package:gowedo/util/util.dart';

import 'new_post_screen.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  FeedBloc _bloc;
  final AudioCache _player = new AudioCache();
  final _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    if (_bloc == null) {
      _bloc = FeedBloc(MyLocalization.of(context), Injector.of(context).postRepository);
      _bloc.setUpFirebaseNotifications();
      _bloc.getPosts();
    }

    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text(MyLocalization.of(context).gowedo, style: TextStyle(color: MyColors.goWeDoWhite),),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(right: 16.0, left: 4.0),
          child: Icon(Icons.menu, color: MyColors.goWeDoWhite, size: 28,),
        ),
        actions: <Widget>[
          NotificationsIndicator(
              notificationStream: _bloc.notificationStream,
              onPressed: _bloc.clearNotifications,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
         // _bloc.addDummyNotification();
          Post newPost = await Navigator.of(context).push(
              MaterialPageRoute(builder: (BuildContext context) => NewPostScreen()));

          if (newPost != null) {
            _bloc.getPosts();
            doAfterBuild(() => _controller.jumpTo(0));
          }
        },
        child: Icon(Icons.add, color: MyColors.goWeDoWhite, size: 28,),
      ),
      body: StreamBuilder<FeedState>(
        stream: _bloc.stateStream,
        initialData: FeedState(stateType: StateType.waiting),
        builder: (context, snapshot) {
          if (snapshot.data?.stateType == StateType.error) {
            return ErrorWithRefreshButton(
                error: snapshot.data.error,
                onRefreshClicked: () => _bloc?.getPosts()
            );

          } else if (snapshot.data?.stateType == StateType.loading && snapshot.data.posts?.isEmpty == true) {
            return const Center(child: CircularProgressIndicator());

          } else {
            return RefreshIndicator(
              onRefresh: () async => _bloc.getPosts(),
              notificationPredicate: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.extentAfter < 100) {
                  _bloc?.getPosts(loadMore: true);
                }
                return true;
              },
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  snapshot.data?.stateType != StateType.refreshing
                      ? ListView.builder(
                      padding: EdgeInsets.all(4.0),
                      controller: _controller,
                      itemCount: snapshot.data.posts == null ? 0 : snapshot.data.posts.length,
                      itemBuilder: (context, index) {
                        final Post post = snapshot.data.posts[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Card(
                            elevation: 8.0,
                            child: InkWell(
                              onTap: () => _player.play(getRandomHello()),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Stack(
                                    alignment: Alignment.centerLeft,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                        child: ClipRRect(
                                            borderRadius: BorderRadius.circular(20),
                                            child: Image.asset(MyImages.govedo, width: 40, height: 40,)
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 56),
                                        child: Text(post.author, style: TextStyle(fontSize: 18),),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(Icons.more_vert),
                                        ),
                                      )
                                    ],
                                  ),
                                  Center(
                                    child: post.image != null
                                        ? Util.getImage(post.image, fit: BoxFit.fitWidth, withWrapper: true)
                                        : Image.file(post.imageFile, fit: BoxFit.cover, width: double.infinity),
                                  ),
                                  const SizedBox(height: 10,),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(post.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
                                  ),
                                  const SizedBox(height: 5,),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(post.description, style: TextStyle(fontSize: 15),),
                                  ),
                                  const SizedBox(height: 10,),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Icon(Icons.location_on, color: MyColors.goWeDoLightGray, size: 16,),
                                        const SizedBox(width: 5,),
                                        Text(post.location, style: TextStyle(color: MyColors.goWeDoLightGray, fontSize: 13),),
                                        Flexible(
                                            flex: 1,
                                            child: SizedBox(width: double.infinity,)
                                        ),
                                        Icon(Icons.date_range, color: MyColors.goWeDoLightGray, size: 16,),
                                        const SizedBox(width: 5,),
                                        Text(MyLocalization.of(context).getDayMonthYearString(DateTime.parse(post.creationDate)),
                                          style: TextStyle(color: MyColors.goWeDoLightGray, fontSize: 13),),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12,),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                  ) : const Center(child: CircularProgressIndicator()),
                  _buildShowNewPostsButton(snapshot.data)
                ],
              ),
            );
          }
        }
      ),
    );
  }

  Widget _buildShowNewPostsButton(FeedState state) {
    return AnimatedPositioned(
      top: state.newNotification == null ? -50 : 10,
      duration: Duration(milliseconds: state.newNotification == null ? 700 : 400),
      curve: ElasticInCurve(),
      child: AnimatedOpacity(
        opacity: state.newNotification == null ? 0.0 : 1.0,
        duration: Duration(milliseconds: 800),
        curve: state.newNotification == null ? ElasticInCurve() : ElasticOutCurve(),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0)
          ),
          color: MyColors.goWeDoBlue,
          elevation: 10,
          child: InkWell(
            borderRadius: BorderRadius.circular(64.0),
            onTap: _bloc.refreshFeed,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(MyLocalization.of(context).showNewPosts,
                style: TextStyle(
                    color: MyColors.goWeDoWhite,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bloc?.dispose();
    _controller?.dispose();
    super.dispose();
  }
}
