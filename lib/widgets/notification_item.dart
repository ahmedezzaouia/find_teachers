import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:maroc_teachers/modals/notification.dart';
import 'package:maroc_teachers/screens/teacher_Profile.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationItem extends StatefulWidget {
  final NotificationFeed notification;

  const NotificationItem({Key key, this.notification}) : super(key: key);

  @override
  _NotificationItemState createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  String notificationItemText = '';
  @override
  Widget build(BuildContext context) {
    configureMediaPreview();
    return Container(
      margin: const EdgeInsets.all(8),
      // color: Colors.red,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _goToUserProfile,
                child: CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 27,
                  child: CircleAvatar(
                    backgroundImage:
                        NetworkImage(widget.notification.avatarImg),
                    radius: 26,
                  ),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        text: widget.notification.username,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 12),
                        children: <TextSpan>[
                          TextSpan(
                            text: notificationItemText,
                            style:
                                TextStyle(color: Colors.black87, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                        timeago.format(widget.notification.timestamp.toDate())),
                  ],
                ),
              ),
              SizedBox(width: 5),
              widget.notification.type != 'follow'
                  ? Expanded(
                      flex: 1,
                      child: CachedNetworkImage(
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                          imageUrl: widget.notification.postImage),
                    )
                  : Container(
                      height: 20,
                      width: 40,
                    )
            ],
          ),
          Divider(),
        ],
      ),
    );
  }

  configureMediaPreview() {
    if (widget.notification.type == 'like') {
      notificationItemText = ' Likes your post';
    } else if (widget.notification.type == 'follow') {
      notificationItemText = ' Started following you.';
    } else {
      notificationItemText = ' Reply:${widget.notification.comment}';
    }
  }

  _goToUserProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (ctx) =>
                TeacherProfile(profileId: widget.notification.userId)));
  }
}
