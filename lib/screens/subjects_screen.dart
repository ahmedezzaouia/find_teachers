import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:maroc_teachers/providers/auth.dart';
import 'package:maroc_teachers/screens/auth_screen.dart';
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
    } else {
      Navigator.of(context).pushNamed(TeacherManagementScreen.routeNamed);
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero).then(
      (_) {
        Provider.of<TeacherProvider>(context, listen: false).getAndSetdata();
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
                      Icon(Icons.exit_to_app),
                      Text('LogOut'),
                    ],
                  ),
                ),
                value: 'LogOut',
              )
            ],
            onChanged: (itemIdentifier) async {
              if (itemIdentifier == 'LogOut') {
                await Provider.of<Auth>(context, listen: false).logOut();
                //wait for state to complete before navigating to another screen
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  Phoenix.rebirth(context);
                });
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
                itemBuilder: (ctx, index) =>
                    SubjectItem(category: categories[index]),
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
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('Home')),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), title: Text('Favorite')),
          BottomNavigationBarItem(
              icon: Icon(Icons.supervised_user_circle),
              title: Text('Management')),
        ],
      ),
    );
  }
}
