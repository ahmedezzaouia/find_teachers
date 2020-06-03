import 'package:flutter/material.dart';
import './screens/subjects_screen.dart';
import './screens/auth_screen.dart';
import './screens/favorite_teachers_screen.dart';
import './screens/teacher_management_screen.dart';
import './providers/teacher_provider.dart';
import './screens/edit_teacher_screen.dart';
import './screens/teacher_detail_screem.dart';
import 'package:provider/provider.dart';
import './screens/teachers_overview_screen.dart';
import 'package:maroc_teachers/providers/auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProxyProvider<Auth, TeacherProvider>(
          create: (BuildContext context) => TeacherProvider(null, null),
          update: (BuildContext context, Auth auth, TeacherProvider teach) =>
              TeacherProvider(auth.token, auth.userId),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
            title: 'maroc teachers',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Color(0xFF020251),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: auth.isAuth
                ? SubjectsScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, snapShot) => AuthScreen(),
                  ),
            routes: {
              TeachersOverviewScreen.routeNamed: (context) =>
                  TeachersOverviewScreen(),
              TeacherDetaillScreen.routeNamed: (context) =>
                  TeacherDetaillScreen(),
              EditTeacherScreen.routeNamed: (context) => EditTeacherScreen(),
              FavoriteTeachersScreen.routeNamed: (context) =>
                  FavoriteTeachersScreen(),
              TeacherManagementScreen.routeNamed: (context) =>
                  TeacherManagementScreen(),
            },
            onUnknownRoute: (ctx) {
              return MaterialPageRoute(builder: (ctx) => SubjectsScreen());
            }),
      ),
    );
  }
}
