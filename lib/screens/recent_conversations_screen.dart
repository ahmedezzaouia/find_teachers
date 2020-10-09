import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:maroc_teachers/modals/conversation.dart';
import 'package:maroc_teachers/providers/authProvider.dart';
import 'package:maroc_teachers/services/db_service.dart';
import 'package:maroc_teachers/widgets/conversation_snippet_item.dart';
import 'package:provider/provider.dart';

class RecentConversationsScreen extends StatefulWidget {
  static const routeName = '/Recent-Conversations';

  @override
  _RecentConversationsScreenState createState() =>
      _RecentConversationsScreenState();
}

class _RecentConversationsScreenState extends State<RecentConversationsScreen> {
  double _deviceHeight;
  double _deviceWidth;
  AuthProvider _auth;
  String _userSearch = '';

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Recent Conversations'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: _recentConversationUI(),
    );
  }

  Widget _recentConversationUI() {
    return Builder(builder: (_context) {
      _auth = Provider.of<AuthProvider>(_context);
      return Container(
        height: _deviceHeight,
        width: _deviceWidth,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: <Widget>[
            _userSearchField(),
            Expanded(
              child: _conversationListViewWidget(),
            ),
          ],
        ),
      );
    });
  }

  Widget _userSearchField() {
    return Container(
      height: _deviceHeight * 0.2,
      width: _deviceWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            'Conversations',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          _searchTextField(),
        ],
      ),
    );
  }

  Widget _searchTextField() {
    return Container(
      height: _deviceHeight * 0.102,
      width: _deviceWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black26,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 2,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          SizedBox(width: 3),
          Container(
            height: _deviceHeight * 0.08,
            width: _deviceHeight * 0.08,
            child: FloatingActionButton(
              onPressed: () {},
              child: Icon(Icons.search),
            ),
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onSubmitted: (value) {
                setState(() {
                  _userSearch = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _conversationListViewWidget() {
    return StreamBuilder<List<ConversationSnippet>>(
        stream: DbService.instance
            .getConversationsSnippet(_auth.user?.uid, _userSearch),
        builder: (_context, snapshot) {
          List<ConversationSnippet> data = snapshot.data;

          if (snapshot.hasData) {
            data.removeWhere((conSnippet) => conSnippet.timestamp == null);
            if (data.length != 0) {
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  return ConversationItem(conversationSnippet: data[index]);
                },
              );
            } else {
              return Center(
                child: Text(
                  'No Conversation Yet.!',
                  style: TextStyle(fontSize: 30, color: Colors.white60),
                ),
              );
            }
          } else {
            return Center(
              child: SpinKitChasingDots(
                color: Colors.blue,
                size: _deviceHeight * 0.05,
              ),
            );
          }
        });
  }
}
