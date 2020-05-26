import 'package:flutter/material.dart';
import '../providers/teacher.dart';

class TeacherManagementItem extends StatelessWidget {
  final Teacher teach;
  TeacherManagementItem({this.teach});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(5),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage(teach.teacherImageUrl),
            ),
            SizedBox(width: 5),
            Expanded(
              flex: 5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    teach.teaherName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Teaching ${teach.teachingSubject}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(width: 5),
                  Text(
                    teach.teacherDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  )
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  IconButton(icon: Icon(Icons.edit), onPressed: () {}),
                  IconButton(icon: Icon(Icons.delete), onPressed: () {})
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
