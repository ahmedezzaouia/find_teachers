import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Comment {
  final String id;
  final String username;
  final String avatarUrl;
  final String commentText;
  final String userId;
  final Timestamp timestamp;
  final String postOwner;
  final String postId;

  Comment({
    this.id,
    this.username,
    this.avatarUrl,
    this.commentText,
    this.userId,
    this.timestamp,
    this.postOwner,
    this.postId,
  });

  factory Comment.fromFirebase(DocumentSnapshot doc) {
    return Comment(
      id: doc.documentID,
      avatarUrl: doc['avatarUrl'],
      commentText: doc['comment'],
      username: doc['username'],
      userId: doc['userId'],
      timestamp: doc['timestamp'],
      postOwner: doc['postOwner'],
      postId: doc['postId'],
    );
  }
}
