import 'package:flutter/material.dart';
import './providers/teacher_provider.dart';
import './screens/edit_teacher_screen.dart';
import './screens/subjects_screen.dart';
import './screens/teacher_detail_screem.dart';
import 'package:provider/provider.dart';
import './screens/teachers_overview_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: TeacherProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Color(0xFF020251),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SubjectsScreen(),
        routes: {
          TeachersOverviewScreen.routeNamed: (ctx) => TeachersOverviewScreen(),
          TeacherDetaillScreen.routeNamed: (ctx) => TeacherDetaillScreen(),
          EditTeacherScreen.routeNamed:(ctx) => EditTeacherScreen()
        },
      ),
    );
  }
}
