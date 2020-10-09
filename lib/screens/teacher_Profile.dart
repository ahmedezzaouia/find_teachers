import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:maroc_teachers/modals/notification.dart';
import 'package:maroc_teachers/modals/post.dart';
import 'package:maroc_teachers/providers/authProvider.dart';
import 'package:maroc_teachers/providers/teacher.dart';
import 'package:maroc_teachers/screens/post_screen.dart';
import 'package:maroc_teachers/services/cloud_storage_service.dart';
import 'package:maroc_teachers/services/compress_image.dart';
import 'package:maroc_teachers/services/db_service.dart';
import 'package:maroc_teachers/services/media_service.dart';
import 'package:maroc_teachers/shared/show_dialog.dart';
import 'package:maroc_teachers/widgets/post_item.dart';
import 'package:provider/provider.dart';

class TeacherProfile extends StatefulWidget {
  static const routeNamed = '/teacher-detaill';
  final String profileId;

  const TeacherProfile({
    Key key,
    this.profileId,
  }) : super(key: key);

  @override
  _TeacherProfileState createState() => _TeacherProfileState();
}

class _TeacherProfileState extends State<TeacherProfile>
    with SingleTickerProviderStateMixin {
  AuthProvider _auth;
  String postOreintation = 'grid';
  bool _isPostsSection = true;
  TabController _tabController;
  bool _isFollow = false;
  bool isProfileOwner = false;

  bool _isNameTextEdite = false;
  bool _isCityTextEdite = false;
  bool _isDescriptionEdite = false;

  String _textName = '';
  String _textCity = '';
  String _textDescription = '';

  File _imageProfileFile;

  FocusNode _focusNodeNameText = FocusNode();
  FocusNode _focusNodeCityText = FocusNode();
  FocusNode _focusNodeDescriptionText = FocusNode();

  int _postsCount = 0;
  int _followingsCount = 0;
  int _followersCount = 0;

  @override
  void initState() {
    checkIfProfileOwner();
    getPostsAndFollowingsAndFollowersCount();
    checkIfAlreadyFollow();
    _focusNodeNameText
        .addListener(() => _showTextFieldConfirmation(_focusNodeNameText));
    _focusNodeCityText
        .addListener(() => _showTextFieldConfirmation(_focusNodeCityText));
    _focusNodeDescriptionText.addListener(
        () => _showTextFieldConfirmation(_focusNodeDescriptionText));

    _tabController = TabController(length: 2, vsync: this);

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _focusNodeNameText.dispose();
    _focusNodeCityText.dispose();
    _focusNodeDescriptionText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthProvider>(context);
    print('>>>>>>> TeacherProfile Build.....');
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  _buildProfileHeader(),
                  SizedBox(height: 15),
                  _isPostsSection ? _sectionPosts() : _sectionReviews(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNoPostVector() {
    return Container(
      height: 290,
      child: Column(
        children: [
          Text(
            'No Posts',
            style: GoogleFonts.kaushanScript(
              textStyle: TextStyle(
                fontSize: 30,
                color: Color(0xff6C63FF),
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          Image.asset(
            'assets/no_posts.png',
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return StreamBuilder(
        stream: DbService.instance
            .getUserData(isProfileOwner ? _auth.user.uid : widget.profileId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          Teacher teacherProfile = snapshot.data;
          return Column(
            children: [
              _imageStackProfile(teacherProfile.teacherImageUrl),
              SizedBox(height: 60),
              _isNameTextEdite
                  ? _profileTextFieldEdite(
                      initialValue: teacherProfile.teaherName,
                      focusNode: _focusNodeNameText,
                      isName: true,
                    )
                  : _profileNameTextWiget(teacherProfile),
              SizedBox(height: 10),
              _isCityTextEdite
                  ? _profileTextFieldEdite(
                      initialValue: teacherProfile.teacherLocation,
                      focusNode: _focusNodeCityText,
                    )
                  : _profileCityTextWiget(teacherProfile.teacherLocation),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _messageButton(),
                  SizedBox(width: 7.5),
                  verticalLine(height: 35, width: 1),
                  SizedBox(width: 7.5),
                  _buildFollowOrEditeButton()
                ],
              ),
              SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: _isDescriptionEdite
                    ? _profileTextFieldEdite(
                        initialValue: teacherProfile.teacherDescription,
                        focusNode: _focusNodeDescriptionText,
                        isDescription: true,
                      )
                    : _profileDescriptionTextWidget(teacherProfile),
              ),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildColumnCount('Posts', _postsCount),
                    verticalLine(height: 30, width: 0.5),
                    _buildColumnCount('Followers', _followersCount),
                    verticalLine(height: 30, width: 0.5),
                    _buildColumnCount('Following', _followingsCount),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Column _profileDescriptionTextWidget(Teacher teacherProfile) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: Text(
            teacherProfile.teacherDescription,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade,
          ),
        ),
        if (isProfileOwner)
          _editeProfileElement(ontap: () {
            setState(() {
              _isDescriptionEdite = true;
            });
          })
      ],
    );
  }

  Row _profileCityTextWiget(String teacherLocation) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.location_on, size: 18),
        SizedBox(width: 5),
        Text(
          teacherLocation,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        SizedBox(width: 5),
        if (isProfileOwner)
          _editeProfileElement(ontap: () {
            setState(() {
              _isCityTextEdite = true;
            });
          }),
      ],
    );
  }

  Container _profileNameTextWiget(Teacher teacherProfile) {
    return Container(
      margin: const EdgeInsets.only(left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            teacherProfile.teaherName,
            style: GoogleFonts.playfairDisplay(
              textStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 5),
          if (isProfileOwner)
            _editeProfileElement(
              ontap: () {
                setState(() {
                  _isNameTextEdite = true;
                });
              },
            )
        ],
      ),
    );
  }

  IconButton _editeProfileElement({@required Function ontap}) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(),
      icon: Icon(Icons.create, color: Color(0xff41A8F3), size: 23),
      onPressed: ontap,
    );
  }

  Container _profileTextFieldEdite({
    String initialValue,
    FocusNode focusNode,
    bool isName = false,
    bool isDescription = false,
  }) {
    return Container(
      child: TextFormField(
        focusNode: focusNode,
        initialValue: initialValue,
        maxLength: isDescription ? 288 : 21,
        maxLines: isDescription ? 8 : 1,
        keyboardType: TextInputType.text,
        autofocus: true,
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        textAlign: TextAlign.center,
        onFieldSubmitted: (_input) {
          if (isName) {
            _textName = _input;
          } else if (isDescription) {
            _textDescription = _input;
          } else {
            _textCity = _input;
          }
        },
      ),
    );
  }

  Widget _buildFollowOrEditeButton() {
    if (isProfileOwner) {
      return _editeButton();
    } else {
      return _followButton();
    }
  }

  GestureDetector _editeButton() {
    return GestureDetector(
      onTap: () {
        DbService.instance
            .removePostComments('cb7e097c-905f-4271-a904-aa833f531c3d');
      },
      child: Container(
        alignment: Alignment.center,
        height: 35,
        width: 120,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          'EDITE PROFILE',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  RaisedButton _messageButton() {
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      color: Color(0xff1583D4),
      onPressed: () {},
      icon: Icon(Icons.chat, size: 15, color: Colors.white),
      label: Text(
        'MESSAGE',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  GestureDetector _followButton() {
    return GestureDetector(
      onTap: _handleFollowOrUnfollow,
      child: Container(
        alignment: Alignment.center,
        height: 35,
        width: 120,
        decoration: BoxDecoration(
          color: Color(0xff1583D4),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          _isFollow ? 'UNFOLLOW' : 'FOLLOW',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _sectionReviews() {
    return Column(
      children: [
        _buildTabBarHeader(),
        Container(
          height: 1000,
          color: Colors.purple,
          child: Center(
            child: Text('Reviews Section'),
          ),
        ),
      ],
    );
  }

  Widget _sectionPosts() {
    return Column(
      children: [
        _buildTabBarHeader(),
        StreamBuilder(
          stream: DbService.instance
              .getUserPosts(isProfileOwner ? _auth.user.uid : widget.profileId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            List<Post> posts = snapshot.data;

            return Column(
              children: [
                Divider(),
                _buildtoggleOrientation(),
                Divider(),
                _buildPostsView(posts),
              ],
            );
          },
        ),
        SizedBox(height: 15),
      ],
    );
  }

  Container _buildColumnCount(String title, int profileCount) {
    return Container(
      width: 80,
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xff2B2828),
              ),
            ),
          ),
          SizedBox(height: 15),
          Text(
            profileCount.toString(),
            style: TextStyle(
              fontSize: 13,
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Container _imageStackProfile(String _profileImage) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,

      height: 135,
      // height: 300,
      child: Stack(
        overflow: Overflow.visible,
        children: [
          Image.asset(
            'assets/profile_background.png',
            fit: BoxFit.cover,
            width: double.infinity,
          ),
          Positioned(
            bottom: -50,
            right: 120,
            left: 120,
            child: Container(
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 52,
                backgroundColor: Colors.grey,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  backgroundImage: _imageProfileFile != null
                      ? FileImage(_imageProfileFile)
                      : NetworkImage(_profileImage),
                ),
              ),
            ),
          ),
          if (isProfileOwner)
            Container(
              alignment: Alignment.bottomCenter,
              // color: Colors.amber,
              margin: EdgeInsets.only(left: 100, bottom: 10),
              child: InkWell(
                onTap: _showUpdateImageOptions,
                child: Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.black,
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Container verticalLine({@required double height, @required double width}) {
    return Container(
      height: height,
      width: width,
      color: Color(0xff707070),
    );
  }

  TabBar _buildTabBarHeader() {
    return TabBar(
      controller: _tabController,
      unselectedLabelColor: Colors.black,
      labelPadding: const EdgeInsets.symmetric(vertical: 10),
      indicator: BoxDecoration(
        color: Color(0xff0F2B54),
      ),
      onTap: (index) {
        print('index clicked :$index');
        setState(() {
          if (index == 0) {
            _isPostsSection = true;
          } else {
            _isPostsSection = false;
          }
        });
      },
      tabs: [
        Text(
          'Posts',
          style: TextStyle(fontSize: 16),
        ),
        Text(
          'Reviews',
          style: TextStyle(fontSize: 16),
        )
      ],
    );
  }

  Widget _buildPostsView(List<Post> posts) {
    if (posts.isEmpty) {
      return _buildNoPostVector();
    }
    if (postOreintation == 'grid') {
      return _buildGridViewPosts(posts);
    } else {
      return _buildListViewPosts(posts);
    }
  }

  Widget _buildListViewPosts(List<Post> posts) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      itemBuilder: (BuildContext context, int index) {
        return PostItem(
          post: posts[index],
        );
      },
    );
  }

  Widget _buildGridViewPosts(List<Post> posts) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: posts.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 5,
          mainAxisSpacing: 10,
          childAspectRatio: 3 / 2),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => PostScreen(
                  post: posts[index],
                ),
              ),
            );
          },
          child: Container(
            child: CachedNetworkImage(
              imageUrl: posts[index].mediaUrl,
              placeholder: (context, url) => Container(color: Colors.grey),
              errorWidget: (context, url, error) =>
                  Container(color: Colors.grey),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  Widget _buildtoggleOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () => setTheOrientation('grid'),
          color: postOreintation == 'grid'
              ? Theme.of(context).primaryColor
              : Colors.grey,
          icon: Icon(Icons.grid_on, size: 18),
        ),
        IconButton(
          onPressed: () => setTheOrientation('list'),
          icon: Icon(Icons.list),
          color: postOreintation == 'list'
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
      ],
    );
  }

// ******************************* Functions *********************************

  getPostsAndFollowingsAndFollowersCount() async {
    String userUid = isProfileOwner
        ? Provider.of<AuthProvider>(context, listen: false).user.uid
        : widget.profileId;
    print(
        'techare-profile__getPostsAndFollowingsAndFollowersCount: userUid=$userUid');
    DbService.instance.getPostsCount(userUid).listen((postsCount) {
      setState(() {
        _postsCount = postsCount;
      });
    });

    int followersCount = await DbService.instance.getFollowersCount(userUid);
    setState(() {
      _followersCount = followersCount;
    });
    int followingsCount = await DbService.instance.getFollowingsCount(userUid);
    setState(() {
      _followingsCount = followingsCount;
    });
  }

  setTheOrientation(String view) {
    setState(() {
      postOreintation = view;
    });
  }

  checkIfProfileOwner() {
    String userId = Provider.of<AuthProvider>(context, listen: false).user.uid;
    isProfileOwner = widget.profileId == userId || widget.profileId == null;
  }

  void _editeAndUpdateImageProfile({bool isFromCamera = false}) async {
    try {
      //get the image from phone gallery
      var _pickedImage = await MediaService.instance
          .getImageFromLibrary(fromCamera: isFromCamera);

      if (_pickedImage != null) {
        setState(() {
          _imageProfileFile = File(_pickedImage.path);
        });
        // compress image to reduce the size
        File compressedFile = await compressImage(File(_pickedImage.path), '',
            isImageForProfile: true);
        //upload image to firebase storage
        var uploadedImage = await CloudStorageService.instance
            .uplodeUserImage(_auth.user.uid, compressedFile);
        String mediaUrl = await uploadedImage.ref.getDownloadURL();
        //send imageUrl to User firstore
        DbService.instance.updateUserProfileData(
          userUid: _auth.user.uid,
          imageProfile: mediaUrl,
          newName: '',
          newLocation: '',
          newDesctiption: '',
        );
      }
      Navigator.pop(context);
    } on Exception catch (e) {
      print(
          '<<<<<<<<<*Error accured with _editeAndUpdateImageProfile function :${e.toString()}*>>>>>>>>');
      setState(() {
        _imageProfileFile = null;
      });
    }
  }

  _showUpdateImageOptions() {
    ShowDialogWidget.instance.showSimpleDialog(
        context: context,
        title: 'Update your Image.',
        options: [
          Column(
            children: [
              SimpleDialogOption(
                onPressed: () =>
                    _editeAndUpdateImageProfile(isFromCamera: true),
                child: Text('Camera',
                    style: TextStyle(fontSize: 18, color: Colors.blue)),
              ),
              SimpleDialogOption(
                onPressed: _editeAndUpdateImageProfile,
                child: Text('Gallery',
                    style: TextStyle(fontSize: 18, color: Colors.blue)),
              ),
            ],
          ),
        ]);
  }

  void resetWidgets() {
    setState(() {
      _isNameTextEdite = false;
      _isCityTextEdite = false;
      _isDescriptionEdite = false;
    });
    _textName = '';
    _textCity = '';
    _textDescription = '';
  }

  _showTextFieldConfirmation(FocusNode _focusNode) {
    if (!_focusNode.hasFocus) {
      showDialog(
        context: context,
        child: SimpleDialog(
          title: Text('do you want to save this change ?'),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SimpleDialogOption(
                  onPressed: () {
                    DbService.instance.updateUserProfileData(
                      userUid: _auth.user.uid,
                      imageProfile: '',
                      newName: _textName,
                      newLocation: _textCity,
                      newDesctiption: _textDescription,
                    );
                    resetWidgets();
                    Navigator.pop(context);
                  },
                  child: Text('Yes'),
                ),
                SimpleDialogOption(
                    onPressed: () {
                      resetWidgets();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'No',
                      style: TextStyle(color: Colors.red),
                    )),
              ],
            ),
          ],
        ),
      );
    }
  }

  checkIfAlreadyFollow() async {
    String currentUserID =
        Provider.of<AuthProvider>(context, listen: false).user.uid;
    _isFollow =
        await DbService.instance.isFollowing(currentUserID, widget.profileId);
    setState(() {});
    print('check is follow $_isFollow');
  }

  void _handleFollowOrUnfollow() {
    bool oldIsFollowStatus = _isFollow;

    try {
      if (!isProfileOwner) {
        setState(() {
          _isFollow = !_isFollow;
        });

        if (_isFollow) {
          DbService.instance.followUser(_auth.user.uid, widget.profileId);
          _sendNotificationToFollowingUser();
        } else {
          DbService.instance.unFollowUser(_auth.user.uid, widget.profileId);
        }
      }
    } on Exception catch (e) {
      setState(() {
        _isFollow = oldIsFollowStatus;
      });
      print(
          '<<<<<<<<<*Error accured with handleFollowORUnFollow function :${e.toString()}*>>>>>>>>');
    }
  }

  _sendNotificationToFollowingUser() {
    NotificationFeed notification = NotificationFeed(
      username: _auth.user.displayName,
      userId: _auth.user.uid,
      avatarImg: _auth.user.photoUrl,
    );
    DbService.instance.sendNotificationFollow(
        notification: notification, followedUser: widget.profileId);
    DbService.instance.addNotificationCount(widget.profileId);
  }
}
