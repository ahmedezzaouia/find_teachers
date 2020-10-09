import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:maroc_teachers/providers/authProvider.dart';
import 'package:maroc_teachers/providers/teacher_provider.dart';
import 'package:maroc_teachers/screens/TimeLine_screen.dart';
import 'package:maroc_teachers/screens/add_post_screen.dart';
import 'package:maroc_teachers/screens/favorite_teachers_screen.dart';
import 'package:maroc_teachers/screens/recent_conversations_screen.dart';
import 'package:maroc_teachers/screens/subjects_screen.dart';
import 'package:maroc_teachers/screens/teacher_Profile.dart';
import 'package:maroc_teachers/screens/teacher_management_screen.dart';
import 'package:provider/provider.dart';

import 'search_screen.dart';

class NavScreen extends StatefulWidget {
  @override
  _NavScreenState createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  List<Widget> _screens = [
    SubjectsScreen(),
    TimeLineScreen(),
    FavoriteTeachersScreen(),
    TeacherManagementScreen(),
    AddPostScreen(),
    SearchScreen(),
    RecentConversationsScreen(),
    TeacherProfile(),
  ];

  Map<String, Icon> icons = {
    'Home': Icon(FontAwesomeIcons.home, size: 20),
    'timeLine': Icon(Icons.timeline, size: 25),
    'Favorite': Icon(Icons.favorite, size: 25),
    'Management': Icon(FontAwesomeIcons.tasks, size: 20),
    'addPost': Icon(Icons.add_circle, size: 25),
    'Search': Icon(Icons.search, size: 25),
    'messenger': Icon(FontAwesomeIcons.facebookMessenger, size: 20),
    'Profile': Icon(Icons.person, size: 30),
  };

  int indexPage = 0;
  Future<bool> _onWillPop() {
    return showDialog<bool>(
      context: context,
      child: AlertDialog(
        title: Text('Are you sure?', style: TextStyle(color: Colors.red)),
        content: Text('you are trying to exist the app.'),
        actions: [
          FlatButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes')),
          FlatButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _screens.length,
      child: Scaffold(
        // body: _screens[indexPage],
        body: WillPopScope(
          onWillPop: _onWillPop,
          child: IndexedStack(
            index: indexPage,
            children: _screens,
          ),
        ),

        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: indexPage,
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          unselectedFontSize: 11.0,
          selectedFontSize: 11.0,
          onTap: (index) {
            setState(() {
              indexPage = index;
            });
          },
          items: icons
              .map(
                (title, icon) => MapEntry(
                  title,
                  BottomNavigationBarItem(
                    icon: icon,
                    title: SizedBox.shrink(),
                  ),
                ),
              )
              .values
              .toList(),
        ),
      ),
    );
  }
}
