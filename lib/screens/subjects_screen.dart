import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:maroc_teachers/providers/authProvider.dart';
import 'package:maroc_teachers/screens/edit_profile_screen.dart';
import 'package:maroc_teachers/screens/recent_conversations_screen.dart';
import 'package:maroc_teachers/screens/teachers_overview_screen.dart';
import 'package:maroc_teachers/services/db_service.dart';
import '../providers/teacher_provider.dart';
import 'package:provider/provider.dart';
import './favorite_teachers_screen.dart';
import './teacher_management_screen.dart';
import '../widgets/appdrawer.dart';
import '../widgets/subjects_item.dart';
import '../modals/category.dart';
import 'package:flutter/scheduler.dart';

class SubjectsScreen extends StatefulWidget {
  static const routeNamed = '/subject-screen';

  @override
  _SubjectsScreenState createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  void ontapTapped(index) {
    print(index);
    if (index == 0) {
      Navigator.of(context).pushReplacementNamed(SubjectsScreen.routeNamed);
    } else if (index == 1) {
      Navigator.of(context).pushNamed(FavoriteTeachersScreen.routeNamed);
    } else if (index == 2) {
      Navigator.of(context).pushNamed(TeacherManagementScreen.routeNamed);
    } else {
      Navigator.pushNamed(context, RecentConversationsScreen.routeName);
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero).then(
      (_) async {
        Provider.of<TeacherProvider>(context, listen: false).getAndSetdata();
        //update the userLastSeen after he enter to the subjects screen
        FirebaseUser user = await FirebaseAuth.instance.currentUser();
        DbService.instance.updateUserLastSeen(user.uid);
        //set the current user to authProvider
        Provider.of<AuthProvider>(context, listen: false).setUser(user);
        final fbm = FirebaseMessaging();
        fbm.requestNotificationPermissions();
        fbm.configure(onMessage: (_msg) {
          print('onMessage: $_msg');
          return;
        }, onLaunch: (_msg) {
          print('onLaunch: $_msg');
          return;
        }, onResume: (_msg) {
          print('onResume: $_msg');
          return;
        });
        fbm.subscribeToTopic(user.uid);
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('subjects screen build');
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('My Teachers'),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: <Widget>[
          DropdownButton(
            underline: Container(),
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).primaryIconTheme.color,
            ),
            items: [
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.settings),
                      SizedBox(width: 5),
                      Text('Setting'),
                    ],
                  ),
                ),
                value: 'setting',
              ),
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.exit_to_app),
                      SizedBox(width: 5),
                      Text('LogOut'),
                    ],
                  ),
                ),
                value: 'LogOut',
              ),
            ],
            onChanged: (itemIdentifier) async {
              if (itemIdentifier == 'LogOut') {
                await Provider.of<AuthProvider>(context, listen: false)
                    .logOut();
                //wait for state to complete before navigating to another screen
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  Phoenix.rebirth(context);
                });
              } else {
                Navigator.of(context).pushNamed(EditProfileScreen.routeNamed);
              }
            },
          )
        ],
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Image.asset(
              'assets/appbar_image.png',
              fit: BoxFit.cover,
              height: 200,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              color: Colors.white,
              height: size.height / 2 + 100,
              width: size.width,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 2.5,
                  mainAxisSpacing: 2,
                ),
                itemBuilder: (ctx, index) => GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      TeachersOverviewScreen.routeNamed,
                      arguments: {
                        'categoryName': categories[index].subjectName,
                        'imageUrl': categories[index].imageUrl,
                      },
                    );
                  },
                  child: SubjectItem(
                    category: categories[index],
                    isSubjectSelected: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: ontapTapped,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            title: Text('Favorite'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle),
            title: Text('Management'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            title: Text('Chat'),
          ),
        ],
      ),
    );
  }
}
