import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationFeed {
  final String id;
  final String username;
  final String userId;
  final String avatarImg;
  final String postId;
  final String postOwner;
  final String postImage;
  final Timestamp timestamp;
  final String type;
  final String comment;

  NotificationFeed({
    this.id,
    this.username,
    this.userId,
    this.avatarImg,
    this.postId,
    this.postOwner,
    this.postImage,
    this.timestamp,
    this.comment,
    this.type,
  });
  factory NotificationFeed.fromFirebase(DocumentSnapshot _doc) {
    return NotificationFeed(
      id: _doc.documentID,
      username: _doc['username'],
      userId: _doc['userId'],
      avatarImg: _doc['avatarImg'],
      postId: _doc['postId'],
      postOwner: _doc['postOwner'],
      postImage: _doc['postImage'],
      timestamp: _doc['timestamp'],
      type: _doc['type'],
      comment: _doc['comment'],
    );
  }
}
