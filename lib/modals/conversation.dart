import 'package:cloud_firestore/cloud_firestore.dart';

import 'message.dart';

class ConversationSnippet {
  final String id;
  final String conversationID;
  final String name;
  final String image;
  final String lastMessage;
  final Timestamp timestamp;
  final int unSeenCount;

  ConversationSnippet({
    this.id,
    this.conversationID,
    this.image,
    this.lastMessage,
    this.name,
    this.timestamp,
    this.unSeenCount,
  });

  factory ConversationSnippet.fromFirebase(
    DocumentSnapshot _snapshot,
  ) {
    var data = _snapshot.data;
    return ConversationSnippet(
      id: _snapshot.documentID,
      conversationID: data['conversationID'],
      name: data['name'],
      image: data['image'],
      lastMessage: data['lastMessage'],
      timestamp: data['timestamp'] == null ? null : data['timestamp'],
      unSeenCount: data['unSeenCount'],
    );
  }
}

class Conversation {
  final String id;
  final List members;
  final String ownerID;
  final List<Message> messages;

  Conversation({
    this.id,
    this.members,
    this.messages,
    this.ownerID,
  });

  factory Conversation.fromFirebase(DocumentSnapshot _snapshot) {
    var data = _snapshot.data;

    List messages = data['messages'];

    messages = messages.map((mes) {
      return Message(
          senderID: mes['senderID'],
          content: mes['content'],
          timestamp: mes['timestamp'],
          type: mes['type']);
    }).toList();

    return Conversation(
      id: _snapshot.documentID,
      members: data['members'],
      ownerID: data['ownerID'],
      messages: messages,
    );
  }
}
