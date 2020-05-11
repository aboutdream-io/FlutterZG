import 'package:gowedo/models/post.dart';
import 'package:gowedo/util/gowedo.dart';

import '../post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  @override
  Future<List<Post>> getPosts({int offset, int limit}) {
    return GoWeDo.api.getPosts(offset: offset, limit: limit);
  }

  @override
  Future<Post> createPost(Post post) {
    return GoWeDo.api.createPost(post);
  }
}
