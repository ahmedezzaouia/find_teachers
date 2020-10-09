import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Post {
  final String postId;
  // final String profileImage;
  final String ownerId;
  final String username;
  final String userJob;
  final Timestamp timestamp;
  final String description;
  final String mediaUrl;
  final List<dynamic> likes;

  Post({
    @required this.postId,
    @required this.ownerId,
    // @required this.profileImage,
    @required this.username,
    this.userJob,
    @required this.timestamp,
    @required this.description,
    @required this.mediaUrl,
    this.likes,
  });

  factory Post.fromFireBase(DocumentSnapshot _doc) {
    return Post(
      postId: _doc['postId'],
      // profileImage: _doc['profileImage'],
      ownerId: _doc['ownerId'],
      username: _doc['username'],
      timestamp: _doc['timestamp'],
      description: _doc['description'],
      mediaUrl: _doc['mediaUrl'],
      likes: _doc['likes'],
    );
  }
}
