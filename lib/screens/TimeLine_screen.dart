import 'package:flutter/material.dart';
import 'package:maroc_teachers/modals/post.dart';
import 'package:maroc_teachers/providers/authProvider.dart';
import 'package:maroc_teachers/services/db_service.dart';
import 'package:maroc_teachers/shared/app_bar.dart';
import 'package:maroc_teachers/widgets/post_item.dart';
import 'package:provider/provider.dart';

class TimeLineScreen extends StatefulWidget {
  @override
  _TimeLineScreenState createState() => _TimeLineScreenState();
}

class _TimeLineScreenState extends State<TimeLineScreen> {
  AuthProvider _auth;
  bool _isRefresh = false;
  List<Post> previousPosts = [];
  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBarWiget(
        title: 'TimeLine',
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child:
            _isRefresh ? _refreshFutureBuilderPosts() : _futureBuilderPosts(),
      ),
    );
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isRefresh = true;
    });
  }

  Widget _futureBuilderPosts() {
    return FutureBuilder<List<Post>>(
        future: DbService.instance.getPostsFromFollowings(_auth.user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          previousPosts = snapshot.data;
          return listBuilderWidget(previousPosts);
        });
  }

  Widget _refreshFutureBuilderPosts() {
    return FutureBuilder<List<Post>>(
        future: DbService.instance.getPostsFromFollowings(_auth.user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return listBuilderWidget(previousPosts);
          }
          List<Post> posts = snapshot.data;
          return Container(child: listBuilderWidget(posts));
        });
  }

  Widget listBuilderWidget(List<Post> _posts) {
    return Scrollbar(
      child: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (BuildContext context, int index) {
          return PostItem(post: _posts[index]);
        },
      ),
    );
  }
}
