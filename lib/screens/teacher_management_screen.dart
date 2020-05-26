import 'package:flutter/material.dart';
import 'package:maroc_teachers/screens/edit_teacher_screen.dart';
import 'package:maroc_teachers/widgets/appdrawer.dart';
import '../providers/teacher_provider.dart';
import '../widgets/teacher_management_item.dart';
import 'package:provider/provider.dart';

class TeacherManagementScreen extends StatelessWidget {
  static const routeNamed = 'teacher-management';
  @override
  Widget build(BuildContext context) {
    final teachData = Provider.of<TeacherProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Management'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add_circle,
              size: 35,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(EditTeacherScreen.routeNamed);
            },
          ),
          SizedBox(width: 5),
        ],
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      drawer: AppDrawer(),
      body: Container(
        margin: EdgeInsets.only(top: 25),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: ListView.builder(
          itemCount: teachData.iteams.length,
          itemBuilder: (BuildContext context, int index) =>
              TeacherManagementItem(
            teach: teachData.iteams[index],
          ),
        ),
      ),
    );
  }
}
