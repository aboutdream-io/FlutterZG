import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gowedo/models/notification.dart';
import 'package:gowedo/ui/widgets/custom_popup_menu_button.dart';
import 'package:gowedo/util/my_colors.dart';
import 'package:gowedo/util/my_localization.dart';

class NotificationsIndicator extends StatefulWidget {
  const NotificationsIndicator({Key key, this.notificationStream, this.onPressed}) : super(key: key);

  final Stream<List<NewPostNotification>> notificationStream;
  final VoidCallback onPressed;

  @override
  _NotificationsIndicatorState createState() => _NotificationsIndicatorState();
}

class _NotificationsIndicatorState extends State<NotificationsIndicator> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NewPostNotification>>(
      initialData: [],
      stream: widget.notificationStream,
      builder: (context, snapshot) {
        final notifications = snapshot.data;

        return CustomPopupMenuButton<NewPostNotification>(
          offset: Offset(0, 50),
          onTap: widget.onPressed,
          itemBuilder: (context) => notifications?.isNotEmpty == true
              ? notifications.map((notification) =>
              CustomPopupMenuItem<NewPostNotification>(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(MyLocalization.of(context).newPostPrefix + notification.title),
                      const SizedBox(height: 4,),
                      Text(MyLocalization.of(context).byPrefix + notification.author, style: TextStyle(color: Colors.blueGrey, fontSize: 13),),
                    ],
                  ))).toList()
              : [],
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Stack(
                children: <Widget>[
                  Icon(notifications?.isNotEmpty == true
                      ? Icons.notifications
                      : Icons.notifications_none,
                      color: MyColors.goWeDoWhite,
                      size: 28
                  ),
                  if (notifications?.isNotEmpty == true) Positioned(
                    top: 2, right: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: MyColors.goWeDoErrorColor,
                          shape: BoxShape.circle
                      ),
                      child: Text(notifications.length.toString(),
                        style: TextStyle(color: MyColors.goWeDoWhite, fontSize: 10),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
