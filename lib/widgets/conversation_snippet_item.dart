import 'package:flutter/material.dart';
import 'package:maroc_teachers/modals/conversation.dart';
import 'package:maroc_teachers/screens/conversation_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationItem extends StatelessWidget {
  final ConversationSnippet conversationSnippet;
  ConversationItem({this.conversationSnippet});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFF00022e),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => ConversationPage(
                  conversationID: conversationSnippet.conversationID,
                  receiveID: conversationSnippet.id,
                  receiverImage: conversationSnippet.image,
                  receiverName: conversationSnippet.name,
                ),
              ),
            );
          },
          leading: _leadingWidget(),
          title: Text(
            conversationSnippet.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            conversationSnippet.lastMessage,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              color: Colors.white54,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: _trailingWidget(),
        ),
      ),
    );
  }

  Container _leadingWidget() {
    return Container(
      height: 60,
      width: 60,
      child: Stack(
        children: <Widget>[
          ClipOval(
            child: FadeInImage(
              placeholder: AssetImage('assets/profile_placeholder.png'),
              image: NetworkImage(
                conversationSnippet.image,
              ),
              width: 55,
              height: 55,
              fit: BoxFit.cover,
            ),
          ),
          if (conversationSnippet.unSeenCount > 0)
            Align(
              alignment: Alignment.bottomLeft,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red,
                child: Text(
                  conversationSnippet.unSeenCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Container _trailingWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Last Message',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 10),
          Text(
            timeago.format(conversationSnippet.timestamp.toDate()),
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
