import 'package:flutter/material.dart';
import 'package:maroc_teachers/modals/comment.dart';
import 'package:maroc_teachers/modals/notification.dart';
import 'package:maroc_teachers/modals/post.dart';
import 'package:maroc_teachers/providers/authProvider.dart';
import 'package:maroc_teachers/services/db_service.dart';
import 'package:maroc_teachers/shared/app_bar.dart';
import 'package:maroc_teachers/widgets/comment_item.dart';
import 'package:maroc_teachers/widgets/post_item.dart';
import 'package:provider/provider.dart';

class PostScreen extends StatefulWidget {
  static const routeName = '/post-screen';
  final Post post;

  PostScreen({
    Key key,
    @required this.post,
  }) : super(key: key);

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  TextEditingController _textController;
  AuthProvider _auth;
  List<Comment> _comments = [];
  @override
  void initState() {
    _textController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBarWiget(title: 'POST'),
      body: Stack(
        children: [
          ListView(
            children: [
              PostItem(
                post: widget.post,
                isPostScreen: true,
              ),
              _buildComments(),
            ],
          ),
          _textFieldComment(context)
        ],
      ),
    );
  }

  Column _buildComments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_comments.length > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              'Comments',
              style: TextStyle(fontSize: 15),
            ),
          ),
        StreamBuilder<List<Comment>>(
            stream:
                DbService.instance.getPostComments(postId: widget.post.postId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              _comments = snapshot.data;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _comments.length,
                itemBuilder: (BuildContext context, int index) {
                  return CommentItem(
                    comment: _comments[index],
                  );
                },
              );
            }),
        SizedBox(height: 50),
      ],
    );
  }

  Align _textFieldComment(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.white,
        child: TextField(
          controller: _textController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Leave your comment here....',
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.mode_comment,
              size: 25,
              color: Theme.of(context).primaryColor,
            ),
            suffixIcon: FlatButton(
              onPressed: _addComment,
              child: Text(
                'POST',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _addComment() async {
    //get avatar image from database for this user who added this comment
    String avatarImage = await DbService.instance.getUserImage(_auth.user.uid);
    String comment = _textController.text.trim();
    // TODO: usernmae is only diffined for google account not normal account
    try {
      Comment singleComment = Comment(
        avatarUrl: avatarImage,
        commentText: comment,
        username: _auth.user.displayName,
        postId: widget.post.postId,
        postOwner: widget.post.ownerId,
        userId: _auth.user.uid,
      );

      DbService.instance.addComment(comment: singleComment);
      bool isPostOwner = widget.post.ownerId == _auth.user.uid;
      if (!isPostOwner) {
        _sendNotificationCommentToPostOwner(comment);
      }
    } on Exception catch (e) {
      print(
          '<<<<<<<<<*Error accured with _sendComment function :${e.toString()}*>>>>>>>>');
    }
    _textController.clear();
  }

  _sendNotificationCommentToPostOwner(String _comment) {
    NotificationFeed notification = NotificationFeed(
      username: _auth.user.displayName,
      userId: _auth.user.uid,
      postId: widget.post.postId,
      postOwner: widget.post.ownerId,
      avatarImg: _auth.user.photoUrl,
      postImage: widget.post.mediaUrl,
      comment: _comment,
      type: 'comment',
    );
    DbService.instance.sendNotificationComment(notification);
    DbService.instance.addNotificationCount(widget.post.ownerId);
  }
}
