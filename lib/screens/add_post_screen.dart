import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maroc_teachers/modals/post.dart';
import 'package:maroc_teachers/providers/authProvider.dart';
import 'package:maroc_teachers/providers/teacher.dart';
import 'package:maroc_teachers/screens/post_screen.dart';
import 'package:maroc_teachers/services/cloud_storage_service.dart';
import 'package:maroc_teachers/services/compress_image.dart';
import 'package:maroc_teachers/services/db_service.dart';
import 'package:maroc_teachers/services/media_service.dart';
import 'package:maroc_teachers/shared/app_bar.dart';
import 'package:maroc_teachers/widgets/progress.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddPostScreen extends StatefulWidget {
  static const routeName = '/add-post';
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  File _imageFile;
  TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  String postId = Uuid().v4();
  AuthProvider _auth;
  // String avatarUrl = '';
  // @override
  // void initState() {
  //   getUserImage();
  //   super.initState();
  // }

  // getUserImage() async {
  //   String userid = Provider.of(context, listen: false).user.uid;

  //   avatarUrl = await DbService.instance.getUserImage(userid);
  // }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBarWiget(
          title: 'Shared a Post',
          actions: FlatButton(
            onPressed: _uploadePostToDb,
            child: Text(
              'Post',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          )),
      body: ListView(
        children: [
          if (_isLoading) linearProgress(),
          _buildAddPostHeader(),
          _buildAddPostContent(),
        ],
      ),
    );
  }

  Column _buildAddPostContent() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 1000.0,
            ),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'What you want to talk about ?',
                hintStyle: TextStyle(fontSize: 15),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
          ),
        ),
        if (_imageFile != null)
          Container(
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(_imageFile),
                fit: BoxFit.cover,
              ),
            ),
          )
      ],
    );
  }

  Widget _buildAddPostHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StreamBuilder(
              stream: DbService.instance.getUserData(_auth.user.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                Teacher teacherData = snapshot.data;

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey,
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            NetworkImage(teacherData.teacherImageUrl),
                      ),
                    ),
                    SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teacherData.teaherName,
                          style: GoogleFonts.playfairDisplay(
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text('Teacher', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                );
              }),
          IconButton(
            icon: Icon(
              Icons.photo_library,
              color: Colors.blueAccent,
              size: 30,
            ),
            onPressed: () async {
              var pickedImage =
                  await MediaService.instance.getImageFromLibrary();
              setState(() {
                if (pickedImage != null) {
                  _imageFile = File(pickedImage.path);
                }
              });
            },
          )
        ],
      ),
    );
  }

  _uploadePostToDb() async {
    if (_textController.text.isEmpty || _imageFile == null) {
      print('text and image is empty');
      return;
    }
    print('upload post');
    setState(() {
      _isLoading = true;
    });
    try {
      // compress image to reduce the size
      File compressedFile = await compressImage(_imageFile, postId);
      //upload image to firebase storage
      var uploadedImage = await CloudStorageService.instance
          .uplodePostImage(_auth.user.uid, compressedFile, postId);
      String mediaUrl = await uploadedImage.ref.getDownloadURL();

      //create post inside firestore collection
      // String _userProfileImage =
      //     await DbService.instance.getUserImage(_auth.user?.uid);
      // TODO: usernmae is only diffined for google account
      Post post = Post(
        mediaUrl: mediaUrl,
        description: _textController.text,
        // profileImage: _userProfileImage,
        ownerId: _auth.user?.uid,
        postId: postId,
        timestamp: Timestamp.now(),
        username: _auth.user.displayName,
        likes: [],
      );

      await DbService.instance.createPost(post);
      //update the postid to a new id
      postId = Uuid().v4();
    } on Exception catch (e) {
      print(
          'error accured while entreing post to db because of :${e.toString()}');
    }
    setState(() {
      _isLoading = false;
      _textController.text = '';
      _imageFile = null;
    });
  }
}
