import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:maroc_teachers/http_exceptions/http_exception.dart';
import 'package:maroc_teachers/providers/teacher.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maroc_teachers/services/db_service.dart';
import 'package:maroc_teachers/services/snackbar_service.dart';

class TeacherProvider with ChangeNotifier {
  String token;
  String userId;

  Future getCurrentUSer() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser user = await _auth.currentUser();
    if (user != null) {
      userId = user.uid;
      notifyListeners();
    }
  }

  List<Teacher> _iteams = [];

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
    final url = 'https://findteachers-e06f1.firebaseio.com/teachers.json';

    try {
      String _userImage = await DbService.instance.getUserImage(userId);
      http.Response response = await http.post(url,
          body: jsonEncode(
            {
              'teaherName': teacher.teaherName,
              'teacherDescription': teacher.teacherDescription,
              'teacherImageUrl': _userImage,
              'teachingSubject': teacher.teachingSubject,
              'creatorId': userId,
            },
          ));
      print(' the result is ${response.body}');
      print(' the status is ${response.statusCode}');
      Teacher teach = Teacher(
        teaherName: teacher.teaherName,
        id: jsonDecode(response.body)['name'],
        teacherDescription: teacher.teacherDescription,
        teacherImageUrl: _userImage,
        teachingSubject: teacher.teachingSubject,
      );
      _iteams.add(teach);

      notifyListeners();
    } catch (error) {
      SnackBarServie.instance
          .showSnackBarError('error occurred during the operation!.');

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
      String _userImage = await DbService.instance.getUserImage(userId);

      http.Response response = await http.patch(
        url,
        body: jsonEncode(
          {
            'teaherName': updateTeacher.teaherName,
            'teacherDescription': updateTeacher.teacherDescription,
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
          Teacher techUpdating = Teacher(
            teaherName: updateTeacher.teaherName,
            id: id,
            teacherDescription: updateTeacher.teacherDescription,
            teacherImageUrl: _userImage,
            teachingSubject: updateTeacher.teachingSubject,
          );
          _iteams[teacherIndex] = techUpdating;
          notifyListeners();
        }
      }
    } catch (error) {
      SnackBarServie.instance
          .showSnackBarError('error occurred during the operation!.');
      throw error;
    }
  }

  // get the data (list of teachers) from firebase server
  Future<String> getAndSetdata({bool filterByUser = false}) async {
    await getCurrentUSer();
    if (userId == null) {
      return '';
    }
    var filterSetting =
        filterByUser ? '?&orderBy="creatorId"&equalTo="$userId"' : '';
    final url =
        'https://findteachers-e06f1.firebaseio.com/teachers.json$filterSetting';
    final urlfav =
        'https://findteachers-e06f1.firebaseio.com/favorites/$userId.json';

    http.Response response = await http.get(url);
    http.Response favoritesResponse = await http.get(urlfav);

    final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
    final extractfavorites =
        jsonDecode(favoritesResponse.body) as Map<String, dynamic>;
    print('extractedData :$extractedData');
    print('extractfavorites : $extractfavorites');
    List<Teacher> loadingTeachersList = [];
    if (extractedData == null) {
      return '';
    }
    extractedData.forEach(
      (teacherId, teacherData) {
        Teacher teach = Teacher(
          creatorID: teacherData['creatorId'],
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
    return response.body;
  }

  //check if there a favorite data for this user
  Future<String> checkFavorites() async {
    final urlfav =
        'https://findteachers-e06f1.firebaseio.com/favorites/$userId.json';

    http.Response favoritesResponse = await http.get(urlfav);
    print('check favorites data :${favoritesResponse.body}');
    return favoritesResponse.body;
  }
}
