import 'package:flutter/material.dart';
import '../modals/category.dart';
import '../screens/teachers_overview_screen.dart';
class SubjectItem extends StatelessWidget {
  final Category category;
  SubjectItem({@required this.category});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(TeachersOverviewScreen.routeNamed, arguments: {
          'categoryId': category.id,
          'imageUrl': category.imageUrl,
        });
      },
      child: Card(
        margin: EdgeInsets.all(10),
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(category.categoryImage),
            SizedBox(height: 10),
            Text(
              category.subjectName,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
