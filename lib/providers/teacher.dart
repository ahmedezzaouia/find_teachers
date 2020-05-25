import 'package:flutter/cupertino.dart';

class Teacher with ChangeNotifier {
  final String teaherName;
  final String teacherDescription;
  final String teacherImageUrl;
  final String id;
  final List<String> categoryId;
  final String categoryName;

  Teacher({
    @required this.teaherName,
    @required this.id,
    @required this.teacherDescription,
    @required this.teacherImageUrl,
    @required this.categoryId,
    @required this.categoryName,
  });
}
