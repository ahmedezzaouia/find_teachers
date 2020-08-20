import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:maroc_teachers/screens/conversation_page.dart';
import 'package:maroc_teachers/screens/edit_profile_screen.dart';
import 'package:maroc_teachers/screens/recent_conversations_screen.dart';
import './screens/subjects_screen.dart';
import './screens/auth_screen.dart';
import './screens/favorite_teachers_screen.dart';
import './screens/teacher_management_screen.dart';
import './providers/teacher_provider.dart';
import './screens/edit_teacher_screen.dart';
import './screens/teacher_detail_screem.dart';
import 'package:provider/provider.dart';
import './screens/teachers_overview_screen.dart';
import 'package:maroc_teachers/providers/authProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(
    Phoenix(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AuthProvider()),
        ChangeNotifierProvider.value(value: TeacherProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) => MaterialApp(
            title: 'maroc teachers',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Color(0xFF020251),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: StreamBuilder(
              stream: FirebaseAuth.instance.onAuthStateChanged,
              builder: (ctx, snapshot) {
                if (snapshot.hasData) {
                  return SubjectsScreen();
                }
                return AuthScreen();
              },
            ),
            routes: {
              ConversationPage.routeName: (ctx) => ConversationPage(),
              RecentConversationsScreen.routeName: (ctc) =>
                  RecentConversationsScreen(),
              EditProfileScreen.routeNamed: (ctx) => EditProfileScreen(),
              SubjectsScreen.routeNamed: (ctx) => SubjectsScreen(),
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
