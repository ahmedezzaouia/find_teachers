import 'package:flutter/cupertino.dart';

class Category {
  final String imageUrl;
  final String categoryImage;
  final String subjectName;

  Category({
    @required this.categoryImage,
    @required this.subjectName,
    @required this.imageUrl,
  });
}

List<Category> categories = [
  Category(
      subjectName: 'Physics',
      categoryImage: 'assets/physics_icon.png',
      imageUrl: 'assets/subjectImage.png'),
  Category(
      subjectName: 'Mathematics',
      categoryImage: 'assets/math_icon.png',
      imageUrl: 'assets/subjectImage.png'),
  Category(
      subjectName: 'informatique',
      categoryImage: 'assets/info_icon.png',
      imageUrl: 'assets/subjectImage.png'),
  Category(
      subjectName: 'Languages',
      categoryImage: 'assets/languages_icon.png',
      imageUrl: 'assets/subjectImage.png'),
];
