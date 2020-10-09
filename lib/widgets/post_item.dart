import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:maroc_teachers/modals/notification.dart';
import 'package:maroc_teachers/modals/post.dart';
import 'package:maroc_teachers/providers/authProvider.dart';
import 'package:maroc_teachers/screens/post_screen.dart';
import 'package:maroc_teachers/screens/teacher_Profile.dart';
import 'package:maroc_teachers/services/cloud_storage_service.dart';
import 'package:maroc_teachers/services/db_service.dart';
import 'package:maroc_teachers/shared/show_dialog.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostItem extends StatefulWidget {
  final Post post;
  final bool isPostScreen;
  PostItem({
    Key key,
    @required this.post,
    this.isPostScreen = false,
  }) : super(key: key);
  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  double _deviceWidth;
  bool _isLiked = false;
  AuthProvider _auth;
  int commentsCount = 0;
  bool isRemovePostLoad = false;

  @override
  void initState() {
    getCommentsStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthProvider>(context, listen: false);
    _isLiked = widget.post.likes.contains(_auth.user.uid);

    _deviceWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        _buildAddPostHeader(),
        _buildMiddlePost(),
      ],
    );
  }

  Widget _buildAddPostHeader() {
    return Container(
      margin: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => TeacherProfile(
                        profileId: widget.post.ownerId,
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey,
                  child: FutureBuilder(
                      future:
                          DbService.instance.getUserImage(widget.post.ownerId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        String _postImage = snapshot.data;
                        return CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(_postImage));
                      }),
                ),
              ),
              SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.username,
                    style: GoogleFonts.playfairDisplay(
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text('Teacher', style: TextStyle(fontSize: 14)),
                  Text(
                    timeago.format(widget.post.timestamp.toDate()),
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          if (_auth.user.uid == widget.post.ownerId)
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {
                showDialog(
                  context: context,
                  child: SimpleDialog(
                    title: Text('Choose an action to do.'),
                    children: [
                      isRemovePostLoad
                          ? Container(
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(),
                            )
                          : Row(
                              children: [
                                SimpleDialogOption(
                                  onPressed: () {},
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 5),
                                    color: Colors.blue[900],
                                    child: Text('Edite Post',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                                SimpleDialogOption(
                                  onPressed: () => _removePost(),
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    color: Colors.red,
                                    child: Text('Remove Post',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
                            )
                    ],
                  ),
                );
              },
            )
        ],
      ),
    );
  }

  Widget _buildMiddlePost() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Text(
              widget.post.description,
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 15),
              softWrap: true,
            ),
          ),
          SizedBox(height: 15),
          Container(
            height: 200,
            width: _deviceWidth,
            child: CachedNetworkImage(
              imageUrl: widget.post.mediaUrl,
              placeholder: (context, url) => Container(
                color: Colors.grey,
              ),
              fit: BoxFit.cover,
            ),
          ),
          _buildPostCount(),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRowPost(
                ontap: () => handlPostLikes(),
                title: 'Like',
                icon: Icons.thumb_up,
                color: _isLiked ? Color(0xff1583D4) : Colors.grey,
              ),
              _buildRowPost(
                  ontap: widget.isPostScreen ? null : _navigateToPostScreen,
                  title: 'Comment',
                  icon: Icons.mode_comment,
                  color: Colors.grey),
              _buildRowPost(
                ontap: () {},
                title: 'Share',
                icon: Icons.share,
                color: Colors.grey,
              ),
            ],
          ),
          Divider(),
        ],
      ),
    );
  }

  Container _buildPostCount() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${widget.post.likes.length} Likes',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xffBABABC),
            ),
          ),
          Text(
            '$commentsCount Comment',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xffBABABC),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowPost({
    @required String title,
    @required IconData icon,
    @required Color color,
    Function ontap,
  }) {
    return GestureDetector(
      onTap: ontap,
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
          ),
          SizedBox(width: 5),
          Text(title),
        ],
      ),
    );
  }

//  ************************************* Functions ******************************

  void _removePost() async {
    String postId = widget.post.postId;
    print('************************ postId======= $postId');

    // 1 step: remove post from postCollection
    await DbService.instance
        .removePost(postId: postId, userUId: widget.post.ownerId);
    //2 step:remove the post's image from firebase storage
    await CloudStorageService.instance
        .removePostImage(widget.post.ownerId, postId);
    //3- remove all activity feed (notifications) related to this post
    await DbService.instance
        .removePostNotifications(widget.post.ownerId, postId);
    //4 - remove all comments related to the Post
    await DbService.instance.removePostComments(postId);
    print('************************ postId======= $postId');
    if (mounted) {
      if (widget.isPostScreen) {
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
      }
    }
  }

  void _navigateToPostScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => PostScreen(post: widget.post),
      ),
    );
  }

  void handlPostLikes() async {
    bool _oldStatus = _isLiked;
    setState(() {
      _isLiked = !_isLiked;
    });

    try {
      if (_isLiked) {
        bool isPostOwner = widget.post.ownerId == _auth.user.uid;
        DbService.instance.likePost(
          postOwnerID: widget.post.ownerId,
          postId: widget.post.postId,
          likedByUser: _auth.user.uid,
        );

        widget.post.likes.add(
          _auth.user.uid,
        );

        if (!isPostOwner) {
          _sendNotificationLikeToPostOwner();
        }
      } else {
        DbService.instance.unLikePost(
          postOwnerID: widget.post.ownerId,
          postId: widget.post.postId,
          likedByUser: _auth.user.uid,
        );
        widget.post.likes.remove(
          _auth.user.uid,
        );
        DbService.instance.removeNotificationLikes(
            postId: widget.post.postId, postOwner: widget.post.ownerId);
      }
    } on Exception catch (e) {
      _isLiked = _oldStatus;
      print(
          '<<<<<<<<<*Error accured with handlPostLikes function :${e.toString()}*>>>>>>>>');
    }
  }

  void getCommentsStream() {
    // add a listener to this event from our stream<List<comment>> every change,the commentsCount will update
    DbService.instance.getPostComments(postId: widget.post.postId).listen(
      (event) {
        if (mounted) {
          setState(() {
            commentsCount = event.length;
          });
        }
        print('coomentsCount ==== $commentsCount');
      },
    );
  }

  _sendNotificationLikeToPostOwner() {
    NotificationFeed notification = NotificationFeed(
      username: _auth.user.displayName,
      userId: _auth.user.uid,
      postId: widget.post.postId,
      postOwner: widget.post.ownerId,
      avatarImg: _auth.user.photoUrl,
      postImage: widget.post.mediaUrl,
      type: 'like',
    );
    DbService.instance.sendNotificationLikes(notification);
    DbService.instance.addNotificationCount(widget.post.ownerId);
  }
}
