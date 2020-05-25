import 'package:flutter/cupertino.dart';

class Teacher with ChangeNotifier {
  final String teaherName;
  final String teacherDescription;
  final String teacherImageUrl;
  final String id;
  final String foundInCategoryName;
  bool isfavorite;

  Teacher({
    @required this.teaherName,
    @required this.id,
    @required this.teacherDescription,
    @required this.teacherImageUrl,
    @required this.foundInCategoryName,
    this.isfavorite = false,
  });

  void toggleFavorite() {
    isfavorite = !isfavorite;
    notifyListeners();
    print('favorite = $isfavorite');
  }
}
