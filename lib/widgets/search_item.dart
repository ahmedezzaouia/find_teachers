import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:maroc_teachers/screens/teacher_Profile.dart';

class SearchItem extends StatelessWidget {
  final String userName;
  final String userImage;
  final String userCity;
  final String userId;

  const SearchItem({
    Key key,
    this.userName,
    this.userImage,
    this.userCity,
    this.userId,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToTeacherProfile(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 2.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(1, 2))],
        ),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.lightBlue,
            backgroundImage: NetworkImage(userImage),
          ),
          title: Text(
            userName,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Row(
            children: [
              Icon(Icons.location_on, size: 15),
              SizedBox(width: 5),
              Text(
                'Las Palmas',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToTeacherProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => TeacherProfile(profileId: userId),
      ),
    );
  }
}
