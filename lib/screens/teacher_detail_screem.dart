import 'package:flutter/material.dart';
import 'package:maroc_teachers/providers/teacher.dart';
import 'package:maroc_teachers/providers/teacher_provider.dart';
import 'package:provider/provider.dart';

class TeacherDetaillScreen extends StatelessWidget {
  static const routeNamed = 'teacher-detaill';

  @override
  Widget build(BuildContext context) {
    print('teacherDetaill screen build');

    final teacherId = ModalRoute.of(context).settings.arguments as String;
    Teacher teacherProfil = Provider.of<TeacherProvider>(context, listen: false)
        .findByTeacherId(teacherId);
    return Scaffold(
      appBar: AppBar(
        title: Text('profile'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Column(
        children: <Widget>[
          Image.network(
            teacherProfil.teacherImageUrl,
            height: 350,
            width: 200,
          ),
          Text(
            teacherProfil.teaherName,
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
          Text(teacherProfil.teacherDescription,
              style: TextStyle(color: Colors.white))
        ],
      ),
    );
  }
}
