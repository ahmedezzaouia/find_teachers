import 'package:flutter/foundation.dart';
import 'package:maroc_teachers/providers/teacher.dart';

class TeacherProvider with ChangeNotifier {
  List<Teacher> _iteams = [
    Teacher(
        teaherName: 'Leonardo Dicaprio',
        teacherDescription:
            'is an American actor,producer, and environmentalist.He has often played unconventional parts',
        teacherImageUrl:
            'https://www.job-hunt.org/images/2018-12-21-DragonImages-AdobeStock_70698768.jpeg',
        id: 't1',
        foundInCategoryName: 'Mathematics'),
    Teacher(
      teaherName: 'Blaise Pascal',
      teacherDescription:
          'is an American actor,producer, and environmentalist.He has often played unconventional parts',
      teacherImageUrl:
          'https://belle-imaging.com/wp-content/uploads/2018/01/Headshots-beautiful-girl-with-long-hair.jpg',
      id: 't2',
      foundInCategoryName: 'Physics',
    ),
    Teacher(
      teaherName: 'Enrico Fermi',
      teacherDescription:
          'is an American actor,producer, and environmentalist.He has often played unconventional parts',
      teacherImageUrl:
          'https://alexstudio.ch/wp-content/uploads/2019/01/business.portrait.cv_.resume.geneva.30.jpg',
      id: 't3',
      foundInCategoryName: 'informatique',
    ),
    Teacher(
        teaherName: 'Ahmed Ezzaouia',
        teacherDescription:
            'is an American actor,producer, and environmentalist.He has often played unconventional parts',
        teacherImageUrl:
            'https://alexstudio.ch/wp-content/uploads/2019/01/business.portrait.cv_.resume.geneva.18.jpg',
        id: 't4',
        foundInCategoryName: 'Languages'),
    Teacher(
      teaherName: 'Enrico Fermi',
      teacherDescription:
          'is an American actor,producer, and environmentalist.He has often played unconventional parts',
      teacherImageUrl:
          'https://www.sprintcv.com/assets/sprintcv-helps-java-consultant-to-generate-amazing-cv-1228395647dab08deb54ccec4dd549db6477ded6803a1f00ac7fbc499b66555c.jpg',
      id: 't5',
      foundInCategoryName: 'informatique',
    ),
    Teacher(
      teaherName: 'Ahmed Ezzaouia',
      teacherDescription:
          'is an American actor,producer, and environmentalist.He has often played unconventional parts',
      teacherImageUrl:
          'https://alexstudio.ch/wp-content/uploads/2019/01/business.portrait.cv_.resume.geneva.18.jpg',
      id: 't6',
      foundInCategoryName: 'Languages',
    ),
    Teacher(
      teaherName: 'Enrico Fermi',
      teacherDescription:
          'is an American actor,producer, and environmentalist.He has often played unconventional parts',
      teacherImageUrl:
          'https://alexstudio.ch/wp-content/uploads/2019/01/business.portrait.cv_.resume.geneva.18.jpg',
      id: 't7',
      foundInCategoryName: 'Physics',
    ),
    Teacher(
      teaherName: 'Ahmed Ezzaouia',
      teacherDescription:
          'is an American actor,producer, and environmentalist.He has often played unconventional parts',
      teacherImageUrl:
          'https://alexstudio.ch/wp-content/uploads/2019/01/business.portrait.cv_.resume.geneva.30.jpg',
      id: 't8',
      foundInCategoryName: 'informatique',
    ),
  ];

  List<Teacher> get iteams {
    return _iteams;
  }

  //find by Category id
  List<Teacher> findByCategory(String categoryName) {
    return _iteams
        .where((tech) => tech.foundInCategoryName == categoryName)
        .toList();
  }

  //find by teacher id
  Teacher findByTeacherId(String id) {
    return _iteams.firstWhere((teach) => teach.id == id);
  }

  //get a list of Favorite items
  List<Teacher> get getFavoriteList {
    return _iteams.where((tech) => tech.isfavorite).toList();
  }

  // add teacher to iteams list

}
