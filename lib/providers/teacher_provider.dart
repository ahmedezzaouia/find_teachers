import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:maroc_teachers/http_exceptions/http_exception.dart';
import 'package:maroc_teachers/providers/teacher.dart';
import 'package:http/http.dart' as http;

class TeacherProvider with ChangeNotifier {
  List<Teacher> _iteams = [
    /*Teacher(
        teaherName: 'Leonardo Dicaprio',
        teacherDescription:
            'is an American actor,producer, and environmentalist.He has often played unconventional parts',
        teacherImageUrl:
            'https://www.job-hunt.org/images/2018-12-21-DragonImages-AdobeStock_70698768.jpeg',
        id: 't1',
        teachingSubject: 'Mathematics'),
    Teacher(
      teaherName: 'Blaise Pascal',
      teacherDescription:
          'is an American actor,producer, and environmentalist.He has often played unconventional parts',
      teacherImageUrl:
          'https://belle-imaging.com/wp-content/uploads/2018/01/Headshots-beautiful-girl-with-long-hair.jpg',
      id: 't2',
      teachingSubject: 'Physics',
    ),
    Teacher(
      teaherName: 'Enrico Fermi',
      teacherDescription:
          'is an American actor,producer, and environmentalist.He has often played unconventional parts',
      teacherImageUrl:
          'https://alexstudio.ch/wp-content/uploads/2019/01/business.portrait.cv_.resume.geneva.30.jpg',
      id: 't3',
      teachingSubject: 'Informatique',
    ),
    Teacher(
        teaherName: 'Ahmed Ezzaouia',
        teacherDescription:
            'is an American actor,producer, and environmentalist.He has often played unconventional parts',
        teacherImageUrl:
            'https://alexstudio.ch/wp-content/uploads/2019/01/business.portrait.cv_.resume.geneva.18.jpg',
        id: 't4',
        teachingSubject: 'Languages'),
    Teacher(
      teaherName: 'Enrico Fermi',
      teacherDescription:
          'is an American actor,producer, and environmentalist.He has often played unconventional parts',
      teacherImageUrl:
          'https://www.sprintcv.com/assets/sprintcv-helps-java-consultant-to-generate-amazing-cv-1228395647dab08deb54ccec4dd549db6477ded6803a1f00ac7fbc499b66555c.jpg',
      id: 't5',
      teachingSubject: 'Informatique',
    ),
    Teacher(
      teaherName: 'Ahmed Ezzaouia',
      teacherDescription:
          'is an American actor,producer, and environmentalist.He has often played unconventional parts',
      teacherImageUrl:
          'https://alexstudio.ch/wp-content/uploads/2019/01/business.portrait.cv_.resume.geneva.18.jpg',
      id: 't6',
      teachingSubject: 'Languages',
    ),
    Teacher(
      teaherName: 'Enrico Fermi',
      teacherDescription:
          'is an American actor,producer, and environmentalist.He has often played unconventional parts',
      teacherImageUrl:
          'https://alexstudio.ch/wp-content/uploads/2019/01/business.portrait.cv_.resume.geneva.18.jpg',
      id: 't7',
      teachingSubject: 'Physics',
    ),
    Teacher(
      teaherName: 'Ahmed Ezzaouia',
      teacherDescription:
          'is an American actor,producer, and environmentalist.He has often played unconventional parts',
      teacherImageUrl:
          'https://alexstudio.ch/wp-content/uploads/2019/01/business.portrait.cv_.resume.geneva.30.jpg',
      id: 't8',
      teachingSubject: 'Informatique',
    ),*/
  ];

  List<Teacher> get iteams {
    return _iteams;
  }

  //find by Category id
  List<Teacher> findByCategory(String categoryName) {
    return _iteams
        .where((tech) => tech.teachingSubject == categoryName)
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
  Future<void> addTeacher(Teacher teacher) async {
    const url = 'https://findteachers-e06f1.firebaseio.com/teachers.json';
    try {
      http.Response response = await http.post(url,
          body: jsonEncode(
            {
              'teaherName': teacher.teaherName,
              'teacherDescription': teacher.teacherDescription,
              'teacherImageUrl': teacher.teacherImageUrl,
              'teachingSubject': teacher.teachingSubject,
            },
          ));
      print(' the result is ${response.body}');
      print(' the status is ${response.statusCode}');
      Teacher teach = Teacher(
        teaherName: teacher.teaherName,
        id: jsonDecode(response.body)['name'],
        teacherDescription: teacher.teacherDescription,
        teacherImageUrl: teacher.teacherImageUrl,
        teachingSubject: teacher.teachingSubject,
      );
      _iteams.add(teach);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  // delete teacher item from the list
  Future<void> deleteTeacher(String id) async {
    final url = 'https://findteachers-e06f1.firebaseio.com/teachers/$id.json';
    int teacherIndex = _iteams.indexWhere((teach) => teach.id == id);
    Teacher existingTeacherItem = _iteams[teacherIndex];
    if (teacherIndex >= 0) {
      _iteams.remove(existingTeacherItem);
      print('remove the item');
      notifyListeners();
    }
    http.Response response = await http.delete(url);
    if (response.statusCode >= 400) {
      _iteams.insert(teacherIndex, existingTeacherItem);
      notifyListeners();
    }
    existingTeacherItem = null;
  }

  //update teacher iteam
  Future<void> updateTeacher(Teacher updateTeacher, String id) async {
    final url = 'https://findteachers-e06f1.firebaseio.com/teachers/$id.json';
    try {
      http.Response response = await http.patch(
        url,
        body: jsonEncode(
          {
            'teaherName': updateTeacher.teaherName,
            'teacherDescription': updateTeacher.teacherDescription,
            'teacherImageUrl': updateTeacher.teacherImageUrl,
            'teachingSubject': updateTeacher.teachingSubject,
          },
        ),
      );
      print('the statue in update method is ${response.statusCode}');
      if (response.statusCode >= 400) {
        throw HttpException('could not update the iteam');
      } else {
        int teacherIndex = _iteams.indexWhere((teach) => teach.id == id);
        if (teacherIndex >= 0) {
          _iteams[teacherIndex] = updateTeacher;
          notifyListeners();
        }
      }
    } catch (error) {
      throw error;
    }
  }

  // get the data (list of teachers) from firebase server
  Future<void> getAndSetdata() async {
    const url = 'https://findteachers-e06f1.firebaseio.com/teachers.json';
    const urlfav = 'https://findteachers-e06f1.firebaseio.com/favorites.json';

    http.Response response = await http.get(url);
    http.Response favoritesResponse = await http.get(urlfav);

    final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
    final extractfavorites =
        jsonDecode(favoritesResponse.body) as Map<String, dynamic>;
    List<Teacher> loadingTeachersList = [];
    if (extractedData == null) {
      return;
    }
    extractedData.forEach(
      (teacherId, teacherData) {
        Teacher teach = Teacher(
          teaherName: teacherData['teaherName'],
          id: teacherId,
          teacherDescription: teacherData['teacherDescription'],
          teacherImageUrl: teacherData['teacherImageUrl'],
          teachingSubject: teacherData['teachingSubject'],
          isfavorite: extractfavorites == null
              ? false
              : extractfavorites[teacherId] ?? false,
        );
        loadingTeachersList.add(teach);
      },
    );
    _iteams = loadingTeachersList;
    notifyListeners();
    print(jsonDecode(response.body));
  }
}
