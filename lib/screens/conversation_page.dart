import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maroc_teachers/modals/conversation.dart';
import 'package:maroc_teachers/modals/message.dart';
import 'package:maroc_teachers/providers/authProvider.dart';
import 'package:maroc_teachers/services/cloud_storage_service.dart';
import 'package:maroc_teachers/services/db_service.dart';
import 'package:maroc_teachers/services/media_service.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationPage extends StatefulWidget {
  static const routeName = '/conversation-page';
  final String conversationID;
  final String receiveID;
  final String receiverImage;
  final String receiverName;
  ConversationPage({
    this.conversationID,
    this.receiveID,
    this.receiverImage,
    this.receiverName,
  });

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  double _deviceHeight;

  double _deviceWidth;
  AuthProvider _auth;
  String _messageText = '';
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.receiverImage),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  widget.receiverName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                _userStatue(),
              ],
            ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: _conversationPageUI(),
    );
  }

  Widget _conversationPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context, listen: false);

        return Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            _messagesListView(),
            Align(
              alignment: Alignment.bottomCenter,
              child: _messageField(),
            ),
          ],
        );
      },
    );
  }

  StreamBuilder<Timestamp> _userStatue() {
    return StreamBuilder<Timestamp>(
        stream: DbService.instance.getUserLastSeen(widget.receiveID),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Timestamp timestamp = snapshot.data;

            if (checkUserIsActivOrNot(timestamp)) {
              return _userIsActiveWidget();
            } else {
              //user is not active
              return Text(
                timeago.format(timestamp.toDate()),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              );
            }
          }

          return Container();
        });
  }

  Row _userIsActiveWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CircleAvatar(
          radius: 5,
          backgroundColor: Colors.green,
        ),
        SizedBox(width: 3),
        Text(
          'Active Now',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  Widget _messagesListView() {
    return Container(
      height: _deviceHeight * 0.78,
      width: _deviceWidth,
      child: StreamBuilder<Conversation>(
        stream: DbService.instance.getConversation(widget.conversationID),
        builder: (_context, snapshot) {
          Conversation conversation = snapshot.data;
          // jump to the botton of the list
          _jumpToBottomListView();
          // reset unSeenCount each time you receive a message of this ReceiverID
          DbService.instance.resetUnSeenCount(_auth.user.uid, widget.receiveID);

          if (conversation != null) {
            if (conversation.messages.length <= 0) {
              return Center(
                child: Text(
                  'Say hello to ${widget.receiverName}',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            return ListView.builder(
              controller: _scrollController,
              itemCount: conversation.messages.length,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              itemBuilder: (BuildContext context, int index) {
                return _messageBubble(
                  isOwnMessage:
                      conversation.messages[index].senderID != widget.receiveID,
                  message: conversation.messages[index],
                );
              },
            );
          } else {
            return Center(
              child: Text(
                'Loading...',
                style: TextStyle(color: Colors.white, fontSize: 33),
              ),
            );
          }
        },
      ),
    );
  }

  Timer _jumpToBottomListView() {
    return Timer(
      Duration(milliseconds: 50),
      () => {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent)
      },
    );
  }

  Widget _messageBubble({bool isOwnMessage, Message message}) {
    List<Color> _colorSheme = isOwnMessage
        ? [Colors.blue, Color.fromRGBO(42, 117, 188, 1)]
        : [Colors.blueGrey, Colors.white60];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment:
            isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          if (!isOwnMessage)
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(widget.receiverImage),
            ),
          SizedBox(
            width: _deviceWidth * 0.02,
          ),
          Container(
            height: message.type == 'text'
                ? _deviceHeight * 0.1 + (message.content.length / 20 * 9)
                : _deviceHeight * 0.5,
            width: message.type == 'text'
                ? _deviceWidth * 0.65
                : _deviceWidth * 0.5,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: isOwnMessage
                  ? BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    )
                  : BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
              gradient: LinearGradient(
                colors: _colorSheme,
                begin: Alignment.bottomLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: message.type == 'text'
                ? _textMessageBubble(message)
                : _imageMessageBubble(message),
          ),
        ],
      ),
    );
  }

  Widget _textMessageBubble(Message message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(message.content),
        Text(
          timeago.format(
            message.timestamp.toDate(),
          ),
        )
      ],
    );
  }

  Widget _imageMessageBubble(Message message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: _deviceHeight * 0.4,
          width: _deviceWidth * 0.5,
          child: CachedNetworkImage(
            imageUrl: message.content,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
        Text(timeago.format(message.timestamp.toDate())),
      ],
    );
  }

  Widget _messageField() {
    return Container(
      height: _deviceHeight * 0.08,
      margin: EdgeInsets.symmetric(
          horizontal: _deviceWidth * 0.03, vertical: _deviceHeight * 0.01),
      decoration: BoxDecoration(
        color: Color.fromRGBO(43, 43, 43, 1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _messageTextField(),
            _sendMessageButton(),
            _sendImageMessageButton(),
          ],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    return Container(
      width: _deviceWidth * 0.55,
      child: TextFormField(
        cursorColor: Colors.white,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Type a message',
          hintStyle: TextStyle(color: Colors.white54),
        ),
        style: TextStyle(color: Colors.white),
        autocorrect: false,
        onChanged: (_input) {
          _formKey.currentState.save();
        },
        onSaved: (_input) {
          _messageText = _input;
        },
        validator: (_input) {
          if (_input.length == 0) {
            return 'please enter a message';
          } else {
            return null;
          }
        },
      ),
    );
  }

  Widget _sendMessageButton() {
    return SizedBox(
      width: _deviceHeight * 0.06,
      height: _deviceHeight * 0.06,
      child: IconButton(
        color: Colors.blueAccent,
        icon: Icon(
          Icons.send,
          size: 30,
        ),
        onPressed: () async {
          // send messsage to firestore
          DbService.instance.sendMessage(
            widget.conversationID,
            Message(
              content: _messageText,
              type: 'text',
              senderID: _auth.user.uid,
              timestamp: null,
            ),
            _auth.user.uid,
          );

          // update the last message for the  users
          DbService.instance.updateLastMessageForTwoUsers(
            _auth.user.uid,
            widget.receiveID,
            Message(
              content: _messageText,
              type: 'text',
              timestamp: Timestamp.now(),
            ),
          );
          //update the UnSeenCount Messages in the receiver
          DbService.instance.updateUnSeenCountMessages(
            widget.receiveID,
            _auth.user.uid,
          );

          // reset or clear the form and lose focus
          _formKey.currentState.reset();
          FocusScope.of(context).unfocus();
        },
      ),
    );
  }

  Widget _sendImageMessageButton() {
    return Container(
      width: _deviceHeight * 0.05,
      height: _deviceHeight * 0.05,
      decoration: BoxDecoration(),
      child: FloatingActionButton(
        child: Icon(Icons.camera_enhance),
        onPressed: () async {
          try {
            //get the file image from galary
            PickedFile _imageFile =
                await MediaService.instance.getImageFromLibrary();

            // and then uplode this file to cloud storage firbase
            var storage = await CloudStorageService.instance.uplodeMediaMessage(
              _auth.user.uid,
              File(_imageFile.path),
            );

            //get the Url of this image file as a String
            String imageUrl = await storage.ref.getDownloadURL();

            //after that, send the message to firestore database

            await DbService.instance.sendMessage(
              widget.conversationID,
              Message(
                content: imageUrl,
                type: 'image',
                senderID: _auth.user.uid,
                timestamp: null,
              ),
              _auth.user.uid,
            );
            // then update the last message for the  users
            await DbService.instance.updateLastMessageForTwoUsers(
              _auth.user.uid,
              widget.receiveID,
              Message(
                content: 'Attachment an Image.',
                type: 'image',
                timestamp: Timestamp.now(),
              ),
            );
            //update the UnSeenCount Messages in the receiver
            DbService.instance.updateUnSeenCountMessages(
              widget.receiveID,
              _auth.user.uid,
            );
          } catch (e) {
            print(
                'error durring the working with image due to :${e.toString()}');
          }
        },
      ),
    );
  }
}

bool checkUserIsActivOrNot(Timestamp timestamp) {
  var currentDate = DateTime.now();
  return timestamp.toDate().isAfter(currentDate.subtract(Duration(hours: 1)));
}
