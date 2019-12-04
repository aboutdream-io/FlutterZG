import 'package:gowedo/util/notifications.dart';

class NewPostNotification {
  String author;
  String title;
  NotificationType type;

  NewPostNotification.fromJsonAndroid(Map<String, dynamic> json)
      : author = json['notification']['body'],
        title = json['notification']['title'],
        type = json['type'];

  NewPostNotification.fromJsonIos(Map<String, dynamic> json)
      : author = json['body'],
        title = json['title'],
        type = json['type'];

  @override
  String toString() {
    return 'NewPostNotification{author: $author, title: $title, type: $type}';
  }
}
