import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:maroc_teachers/modals/education.dart';
import 'package:maroc_teachers/providers/authProvider.dart';
import 'package:maroc_teachers/providers/teacher.dart';
import 'package:maroc_teachers/screens/conversation_page.dart';
import 'package:maroc_teachers/services/db_service.dart';
import 'package:maroc_teachers/widgets/education_item.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class TeacherDetaillScreen extends StatefulWidget {
  static const routeNamed = '/teacher-detaill';

  @override
  _TeacherDetaillScreenState createState() => _TeacherDetaillScreenState();
}

class _TeacherDetaillScreenState extends State<TeacherDetaillScreen> {
  double _deviceHeight;
  double _deviceWidth;
  Teacher teacherData;
  String teacherId;
  List<Education> educationsData = [];
  bool _dataIsArrive = true;
  AuthProvider _auth;

  bool isFavorite;
  String docId;
  @override
  Widget build(BuildContext context) {
    print('teacherDetaill screen build');
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    //receive data from teacher_item
    var receiverData =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;

    teacherId = receiverData['creatorId'];
    isFavorite = receiverData['isFavorite'];
    docId = receiverData['docId'];

    print('creatorId is :$teacherId');

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: _teacherDetailUI(),
    );
  }

  Widget _teacherDetailUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context, listen: false);
        return StreamBuilder<Map<String, dynamic>>(
            stream: DbService.instance.getUserData(teacherId),
            builder: (context, snapshot) {
              var data = snapshot.data;
              if (snapshot.hasData) {
                if (_dataIsArrive) {
                  teacherData = data['teacher'];
                  educationsData = data['education'];

                  _dataIsArrive = false;
                }
                print('list of educations ${data['educations']}');

                return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: _deviceHeight * 0.015),
                      _topRowWidget(),
                      SizedBox(height: _deviceHeight * 0.03),
                      _containerWidget(),
                    ],
                  ),
                );
              } else {
                return Center(
                  child: SpinKitChasingDots(
                    color: Colors.blue,
                    size: _deviceHeight * 0.1,
                  ),
                );
              }
            });
      },
    );
  }

  Widget _messageButtonWidget() {
    return RaisedButton.icon(
      padding: EdgeInsets.symmetric(
          horizontal: _deviceHeight * 0.0512, vertical: _deviceHeight * 0.0103),
      color: Colors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(15),
          bottomLeft: Radius.circular(15),
        ),
      ),
      onPressed: _goToChatPage,
      icon: Icon(
        Icons.chat,
        color: Colors.white,
      ),
      label: Text(
        'Chat',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Container _containerWidget() {
    return Container(
      margin: EdgeInsets.only(
        right: _deviceHeight * 0.036,
      ),
      padding: EdgeInsets.only(
          left: _deviceHeight * 0.0147,
          right: _deviceHeight * 0.0147,
          top: _deviceHeight * 0.0439,
          bottom: _deviceHeight * 0.0147),
      height: ((educationsData.length * 100) + 330).toDouble(),
      width: _deviceWidth * 0.93,
      constraints: BoxConstraints(minHeight: 480),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(
            _deviceHeight * 0.07,
          ),
        ),
      ),
      child: _contentColumn(),
    );
  }

  Column _contentColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _aboutWidget(),
        SizedBox(height: _deviceHeight * 0.01),
        _educationWidget(),
      ],
    );
  }

  Column _educationWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Education',
          style: TextStyle(
            fontSize: _deviceHeight * 0.0264,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: _deviceHeight * 0.01),
        Container(
          height: _deviceHeight * 0.5,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 2), // changes position of shadow
              ),
            ],
          ),
          child: ListView.builder(
            itemCount: educationsData.length,
            itemBuilder: (BuildContext context, int index) {
              return EducationItem(
                education: educationsData[index],
                isProfileSettingPage: true,
              );
            },
          ),
        )
      ],
    );
  }

  Column _aboutWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'About',
          style: TextStyle(
            fontSize: _deviceHeight * 0.0264,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: _deviceHeight * 0.01),
        Text(
          teacherData.teacherDescription,
          style: TextStyle(
            fontSize: _deviceHeight * 0.0205,
          ),
        ),
      ],
    );
  }

  Widget _topRowWidget() {
    return Container(
      width: _deviceWidth * 0.95,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _imageWidget(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                teacherData.teaherName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _deviceHeight * 0.0322,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              _messageButtonWidget(),
              _callButtonWidget(),
            ],
          ),
        ],
      ),
    );
  }

  CircleAvatar _imageWidget() {
    return CircleAvatar(
      radius: _deviceHeight * 0.0905,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: _deviceHeight * 0.0831,
        backgroundImage: NetworkImage(teacherData.teacherImageUrl),
      ),
    );
  }

  RaisedButton _callButtonWidget() {
    return RaisedButton.icon(
      padding: EdgeInsets.symmetric(
          horizontal: _deviceHeight * 0.0512, vertical: _deviceHeight * 0.0103),
      color: Color(0xff006416),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(15),
          bottomLeft: Radius.circular(15),
        ),
      ),
      onPressed: () => _callFunction(teacherData.phoneNumber),
      icon: Icon(
        Icons.call,
        color: Colors.white,
      ),
      label: Text(
        'Phone',
        style: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _callFunction(String _phone) {
    if (_phone == 'enter a phone number') {
      _showDialogMessage('this user doesn\'t have a phone.');
    } else {
      UrlLauncher.launch('tel:$_phone');
    }
  }

  _showDialogMessage(String _message) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(_message),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: Text('ok'),
          ),
        ],
      ),
    );
  }

  void _goToChatPage() async {
    try {
      await DbService.instance.getConversationOrCreate(
        _auth.user.uid,
        teacherId,
        (_conversationID) {
          return Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => ConversationPage(
                receiveID: teacherId,
                conversationID: _conversationID,
                receiverName: teacherData.teaherName,
                receiverImage: teacherData.teacherImageUrl,
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (e.toString().contains('the users has the same uid')) {
        print('no talk with your self ..');
        _showDialogMessage('you can\'t chat with yourself');
      }
    }
  }
}
