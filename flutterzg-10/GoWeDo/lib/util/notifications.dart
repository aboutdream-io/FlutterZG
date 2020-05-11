import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

class Notifications {
  static final Notifications _notifications = Notifications._internal();

  factory Notifications() => _notifications;

  Notifications._internal();

  StreamController<Map<String, dynamic>> _notificationStream;

  final List<Map<String, dynamic>> _notificationsBacklog = [];

  Future<String> get getFirebaseToken => firebaseMessaging.getToken();

  Stream<Map<String, dynamic>> get getNotificationStream {
    if (_notificationStream != null) {
      _closeStream();
    }

    _notificationStream = StreamController<Map<String, dynamic>>();

    Future<void>.delayed(const Duration(milliseconds: 500), _sendBacklog);

    return _notificationStream.stream;
  }

  bool get hasListeners => _notificationStream?.hasListener ?? false;

  Stream<String> get onFirebaseTokenRefresh => firebaseMessaging.onTokenRefresh;

  void _sendBacklog() {
    if (_notificationStream?.hasListener == false) {
      print('No listener!');
      return;
    }

    if (_notificationsBacklog.isNotEmpty) {
      print('Have ${_notificationsBacklog.length} notifications in backlog!');
      final Function forEach = (Map<String, dynamic> notification) {
        _notificationStream.add(notification);
      };
      _notificationsBacklog.forEach(forEach);

      _notificationsBacklog.clear();
    }
  }

  void _closeStream() {
    _notificationStream?.close();
    _notificationStream = null;
  }

  Future<Null> configure() async {
    print('Starting notifications setup!');

    print('Configuring firebase!');
    firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> notification) =>
          _processNotification(notification, NotificationType.onLaunch),
      onMessage: (Map<String, dynamic> notification) =>
          _processNotification(notification, NotificationType.inApp),
      onResume: (Map<String, dynamic> notification) =>
          _processNotification(notification, NotificationType.onResume),
    );

    if (Platform.isIOS) {
      print('Asking for permissions on iOS!');
      firebaseMessaging.requestNotificationPermissions(const IosNotificationSettings());
      final IosNotificationSettings settings = await firebaseMessaging.onIosSettingsRegistered.first
          .timeout(const Duration(seconds: 10), onTimeout: () => null);
      print('Settings registered: $settings');
    }

    return Future<Null>.value();
  }

  Future<Null> _processNotification(
      Map<String, dynamic> notification, NotificationType type) {

    if (type == NotificationType.onLaunch) {
      notification.addAll({'type': NotificationType.onLaunch});
    } else if (type == NotificationType.onResume){
      notification.addAll({'type': NotificationType.onResume});
    } else {
      notification.addAll({'type': NotificationType.inApp});
    }

    if (_notificationStream == null || !_notificationStream.hasListener) {
      print('Adding to backlog: ${notification.toString()}');
      _notificationsBacklog.add(notification);
    } else {
      print('Sending to stream: ${notification.toString()}');
      _notificationStream.add(notification);
    }

    return Future<Null>.value(null);
  }
}

enum NotificationType { onLaunch, inApp, onResume }
