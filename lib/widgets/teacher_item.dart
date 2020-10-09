import 'package:flutter/material.dart';
import '../screens/teacher_Profile.dart';
import '../providers/teacher.dart';
import 'package:provider/provider.dart';

class TeacherItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final teachData = Provider.of<Teacher>(context, listen: false);
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (ctx) =>
                    TeacherProfile(profileId: teachData.creatorID)));
      },
      child: Card(
        margin: EdgeInsets.all(10),
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 5),
            ClipOval(
              child: FadeInImage(
                placeholder: AssetImage('assets/profile_placeholder.png'),
                image: NetworkImage(
                  teachData.teacherImageUrl,
                ),
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
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
              child: Consumer<Teacher>(
                builder: (ctx, tech, child) => IconButton(
                  icon: Icon(
                    teachData.isfavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: () async {
                    await teachData.toggleFavorite(teachData.id);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
