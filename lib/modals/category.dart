import 'package:flutter/cupertino.dart';

class Category {
  final String imageUrl;
  final String categoryImage;
  final String subjectName;
  final String id;

  Category({
    @required this.categoryImage,
    @required this.subjectName,
    @required this.id,
    @required this.imageUrl,
  });
}

List<Category> categories = [
  Category(
      subjectName: 'Physics',
      categoryImage: 'assets/physics_icon.png',
      id: 'c1',
      imageUrl: 'assets/subjectImage.png'),
  Category(
      subjectName: 'Mathematics',
      categoryImage: 'assets/math_icon.png',
      id: 'c2',
      imageUrl: 'assets/subjectImage.png'),
  Category(
      subjectName: 'informatique',
      categoryImage: 'assets/info_icon.png',
      id: 'c3',
      imageUrl: 'assets/subjectImage.png'),
  Category(
      subjectName: 'Languages',
      categoryImage: 'assets/languages_icon.png',
      id: 'c4',
      imageUrl: 'assets/subjectImage.png'),
];
