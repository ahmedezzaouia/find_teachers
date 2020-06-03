import 'package:flutter/material.dart';
import 'package:maroc_teachers/screens/auth_screen.dart';
import 'package:maroc_teachers/screens/favorite_teachers_screen.dart';
import '../screens/teacher_management_screen.dart';
import 'package:maroc_teachers/providers/auth.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Drawer(
      child: Container(
        height: size.height,
        width: size.width,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: <Widget>[
            Image.asset(
              'assets/drawer.jpg',
              height: 200,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
            buildListTile(
              Icons.supervised_user_circle,
              'User Management',
              () {
                Navigator.of(context)
                    .pushNamed(TeacherManagementScreen.routeNamed);
              },
            ),
            Divider(color: Colors.white, height: 1),
            buildListTile(Icons.favorite, 'My Favorites', () {
              Navigator.of(context)
                  .pushReplacementNamed(FavoriteTeachersScreen.routeNamed);
            }),
            Divider(color: Colors.white, height: 1),
            buildListTile(Icons.chat_bubble, 'Chat', () {}),
            Divider(color: Colors.white, height: 1),
            buildListTile(Icons.home, 'Home', () {
              Navigator.of(context).pushReplacementNamed('/');
            }),
            Divider(color: Colors.white, height: 1),
            buildListTile(Icons.exit_to_app, 'Log Out', () async {
              await Provider.of<Auth>(context, listen: false).logOut();
              Navigator.of(context).pop();
            }),
            Divider(color: Colors.white, height: 1),
          ],
        ),
      ),
    );
  }

  ListTile buildListTile(IconData icon, String title, Function ontListTaped) {
    return ListTile(
      onTap: ontListTaped,
      leading: Icon(
        icon,
        size: 45,
        color: Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
