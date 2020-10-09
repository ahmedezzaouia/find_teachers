import 'package:flutter/material.dart';
import 'package:maroc_teachers/modals/notification.dart';
import 'package:maroc_teachers/providers/authProvider.dart';
import 'package:maroc_teachers/services/db_service.dart';
import 'package:maroc_teachers/shared/app_bar.dart';
import 'package:maroc_teachers/widgets/notification_item.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatelessWidget {
  AuthProvider _auth;
  double _deviceHeight;
  @override
  Widget build(BuildContext context) {
    _auth = Provider.of(context, listen: false);
    _deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0XFFE8E8E8),
      appBar: appBarWiget(title: 'NOTIFICATION'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: Text(
                'NOTIFICATION',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    fontSize: 16),
              ),
            ),
            _buildNotifications()
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsNoContent() {
    return Container(
      height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications,
            size: 150,
            color: Colors.blueAccent,
          ),
          Text('you don\'t have any \n notification yet.',
              style: TextStyle(fontSize: 25)),
        ],
      ),
    );
  }

  Widget _buildNotifications() {
    return StreamBuilder<List<NotificationFeed>>(
        stream: DbService.instance.getNotificationFeed(userUid: _auth.user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          DbService.instance.resetNotificationCount(_auth.user.uid);
          List<NotificationFeed> feeds = snapshot.data;
          if (feeds.isEmpty) {
            return Center(child: _buildNotificationsNoContent());
          }
          return Container(
            constraints: BoxConstraints(minHeight: 600),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: feeds.length,
              itemBuilder: (BuildContext context, int index) {
                return NotificationItem(
                  notification: feeds[index],
                );
              },
            ),
          );
        });
  }
}
