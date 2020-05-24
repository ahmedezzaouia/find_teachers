import 'package:flutter/material.dart';
import 'package:maroc_teachers/providers/teacher.dart';
import '../widgets/teacher_item.dart';
import '../providers/teacher_provider.dart';
import 'package:provider/provider.dart';

class TeachersOverviewScreen extends StatelessWidget {
  static const routeNamed = 'teachers-overview';
  @override
  Widget build(BuildContext context) {
    final routeArguments = ModalRoute.of(context).settings.arguments as Map;
    final categoryId = routeArguments['categoryId'];
    final subjectImage = routeArguments['imageUrl'];
    final teach = Provider.of<TeacherProvider>(context, listen: false);
    List<Teacher> techByCategory = teach.findByCategory(categoryId);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Image.asset(
            subjectImage,
            fit: BoxFit.cover,
            height: 230,
            width: double.infinity,
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: techByCategory.length,
                  itemBuilder: (BuildContext context, int index) =>
                      ChangeNotifierProvider.value(
                          value: techByCategory[index], child: TeacherItem()),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
