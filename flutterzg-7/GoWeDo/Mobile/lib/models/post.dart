import 'dart:io';

class Post {
  String title;
  String description;
  String image;
  String creationDate;
  String location;
  File imageFile;

  Post.fromApi(Map<String, dynamic> json)
      : title = json['title'] as String,
        description = json['description'] as String,
        image = json['image'] as String,
        location = 'Zagreb',
        creationDate = json['created_at'] as String;

  Post.dummyFromFile(String title, String description, File file)
      : title = title,
        description = description,
        imageFile = file,
        location = 'Zagreb',
        creationDate = 'Today';
}
