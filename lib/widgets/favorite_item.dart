import 'package:flutter/material.dart';
import 'package:maroc_teachers/providers/teacher.dart';
import 'package:maroc_teachers/screens/teacher_detail_screem.dart';
import 'package:provider/provider.dart';

class FavoriteItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final teacher = Provider.of<Teacher>(context, listen: false);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(TeacherDetaillScreen.routeNamed,
            arguments: teacher.creatorID);
      },
      child: Card(
        margin: EdgeInsets.all(5),
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(teacher.teacherImageUrl),
                ),
                Consumer<Teacher>(
                  builder: (ctx, tech, child) => IconButton(
                      icon: teacher.isfavorite
                          ? Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 30,
                            )
                          : Icon(
                              Icons.favorite_border,
                              color: Colors.red,
                              size: 30,
                            ),
                      onPressed: () async {
                        await teacher.toggleFavorite();
                      }),
                )
              ],
            ),
            SizedBox(height: 5),
            Text(
              teacher.teaherName,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            Text('Teach ${teacher.teachingSubject}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            SizedBox(height: 5),
            Text(
              teacher.teacherDescription,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
