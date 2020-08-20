import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String content;
  final String senderID;
  final String type;
  final Timestamp timestamp;
  Message({
    this.content,
    this.senderID,
    this.timestamp,
    this.type,
  });
}
