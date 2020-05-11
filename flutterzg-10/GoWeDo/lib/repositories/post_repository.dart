import 'dart:io';

import 'package:gowedo/models/post.dart';

abstract class PostRepository {
  Future<List<Post>> getPosts({int offset, int limit});
  Future<Post> createPost(Post post);
}
