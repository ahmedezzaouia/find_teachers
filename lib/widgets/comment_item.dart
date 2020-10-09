import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroc_teachers/modals/comment.dart';
import 'package:maroc_teachers/providers/authProvider.dart';
import 'package:maroc_teachers/services/db_service.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentItem extends StatefulWidget {
  final Comment comment;

  const CommentItem({
    Key key,
    this.comment,
  }) : super(key: key);

  @override
  _CommentItemState createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool _isCommentExpanded = false;
  AuthProvider _auth;

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthProvider>(context, listen: false);
    bool _isCommentOwner = _auth.user.uid == widget.comment.userId;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue,
            backgroundImage: NetworkImage(widget.comment.avatarUrl),
          ),
          SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
            decoration: BoxDecoration(
              color: Color(0xffF1F1F3),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 255,
                  height: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.comment.username,
                        style: GoogleFonts.playfairDisplay(
                          textStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _isCommentOwner
                          ? DropdownButton(
                              underline: Container(),
                              icon: Icon(
                                Icons.more_vert,
                                size: 13,
                              ),
                              items: [
                                DropdownMenuItem(
                                  child: Text(
                                    'Remove',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  value: 'Remove',
                                )
                              ],
                              onChanged: (_onchange) {
                                if (_onchange == 'Remove') {
                                  _showRemoveDialog();
                                }
                              },
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
                Text(
                  timeago.format(widget.comment.timestamp.toDate()),
                  style: TextStyle(fontSize: 9, color: Colors.grey),
                ),
                Container(
                  width: 240,
                  constraints: _isCommentExpanded
                      ? BoxConstraints()
                      : BoxConstraints(maxHeight: 120),
                  child: Text(
                    widget.comment.commentText,
                    style: TextStyle(
                      fontSize: 11,
                    ),
                    softWrap: true,
                    overflow: _isCommentExpanded
                        ? TextOverflow.fade
                        : TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    maxLines: _isCommentExpanded ? null : 6,
                  ),
                ),
                if (widget.comment.commentText.length >= 346)
                  Container(
                    width: 250,
                    height: 20,
                    alignment: Alignment.centerRight,
                    child: FlatButton(
                      onPressed: _expandCommentWidget,
                      child: Text(
                        _isCommentExpanded ? 'Show less' : 'Show more...',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _expandCommentWidget() {
    setState(() {
      _isCommentExpanded = !_isCommentExpanded;
    });
  }

  _showRemoveDialog() {
    showDialog(
      context: context,
      child: AlertDialog(
        title: Text('Are you sure?'),
        content: Text('You are trying to remove your comment.'),
        actions: [
          FlatButton(
            child: Text('Yes'),
            onPressed: () {
              DbService.instance.removeComment(
                postId: widget.comment.postId,
                commentId: widget.comment.id,
              );

              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text('No'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
