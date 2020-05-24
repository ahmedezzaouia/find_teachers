import 'package:flutter/material.dart';
import '../screens/teacher_detail_screem.dart';
import '../providers/teacher.dart';
import 'package:provider/provider.dart';

class TeacherItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final teachData = Provider.of<Teacher>(context, listen: false);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(TeacherDetaillScreen.routeNamed,
            arguments: teachData.id);
      },
      child: Card(
        margin: EdgeInsets.all(10),
        elevation: 4.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 5),
            CircleAvatar(
              backgroundImage: NetworkImage(teachData.teacherImageUrl),
              radius: 35,
            ),
            SizedBox(width: 10),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    teachData.teaherName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 5),
                  Text(
                    teachData.teacherDescription,
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                  SizedBox(height: 10)
                ],
              ),
            ),
            Expanded(
                child: IconButton(
                    icon: Icon(Icons.favorite_border), onPressed: () {}))
          ],
        ),
      ),
    );
  }
}
