import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:maroc_teachers/modals/education.dart';
import 'package:maroc_teachers/providers/teacher.dart';
import 'package:maroc_teachers/services/db_service.dart';
import 'package:maroc_teachers/widgets/education_item.dart';
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
  List<Education> educationsData = [];
  bool _dataIsArrive = true;

  @override
  Widget build(BuildContext context) {
    print('teacherDetaill screen build');
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    String teacherId = ModalRoute.of(context).settings.arguments as String;
    print('creatorId is :$teacherId');

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: _teacherDetailUI(teacherId),
    );
  }

  Widget _teacherDetailUI(String _teacherId) {
    return Builder(
      builder: (BuildContext _context) {
        return StreamBuilder<Map<String, dynamic>>(
            stream: DbService.instance.getUserData(_teacherId),
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
                      _stackWidget()
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

  Stack _stackWidget() {
    return Stack(
      children: <Widget>[
        _containerWidget(),
        Positioned(
          right: _deviceHeight * 0.1,
          top: -_deviceHeight * 0.05,
          child: _favoriteButtonWidget(),
        ),
        Positioned(
          right: _deviceHeight * 0.22,
          top: -_deviceHeight * 0.05,
          child: _messageButtonWidget(),
        ),
      ],
      overflow: Overflow.visible,
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
        SizedBox(height: _deviceHeight * 0.01),
        Text(
          'Education',
          style: TextStyle(
            fontSize: _deviceHeight * 0.0264,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: _deviceHeight * 0.01),
        Expanded(
          child: ListView.builder(
            itemCount: educationsData.length,
            itemBuilder: (BuildContext context, int index) {
              return EducationItem(
                education: educationsData[index],
                isProfilePage: true,
              );
            },
          ),
        )
      ],
    );
  }

  Container _messageButtonWidget() {
    return Container(
      height: _deviceHeight * 0.1,
      width: _deviceHeight * 0.1,
      decoration: BoxDecoration(
        color: Color(0xff00388B),
        borderRadius: BorderRadius.circular(50),
      ),
      child: IconButton(
        icon: Icon(
          Icons.message,
          color: Colors.white,
          size: _deviceHeight * 0.05,
        ),
        onPressed: () {},
      ),
    );
  }

  Container _favoriteButtonWidget() {
    return Container(
      height: _deviceHeight * 0.1,
      width: _deviceHeight * 0.1,
      decoration: BoxDecoration(
        color: Color(0xff00388B),
        borderRadius: BorderRadius.circular(50),
      ),
      child: IconButton(
        icon: Icon(
          Icons.favorite,
          color: Colors.white,
          size: _deviceHeight * 0.05,
        ),
        onPressed: () {},
      ),
    );
  }

  Row _topRowWidget() {
    return Row(
      children: <Widget>[
        SizedBox(width: _deviceHeight * 0.0293),
        _imageWidget(),
        SizedBox(width: _deviceHeight * 0.0220),
        Column(
          mainAxisSize: MainAxisSize.min,
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
            _callButtonWidget(),
          ],
        ),
      ],
    );
  }

  CircleAvatar _imageWidget() {
    return CircleAvatar(
      radius: _deviceHeight * 0.0805,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: _deviceHeight * 0.0731,
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
}
