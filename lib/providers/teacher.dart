import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class Teacher with ChangeNotifier {
  final String teaherName;
  final String teacherDescription;
  final String teacherImageUrl;
  final String id;
  final String teachingSubject;
  bool isfavorite;

  Teacher({
    @required this.teaherName,
    @required this.id,
    @required this.teacherDescription,
    @required this.teacherImageUrl,
    @required this.teachingSubject,
    this.isfavorite = false,
  });

  Future<void> toggleFavorite() async {
    final url = 'https://findteachers-e06f1.firebaseio.com/favorites/$id.json';
    bool oldStatus = isfavorite;
    isfavorite = !isfavorite;
    notifyListeners();
    try {
      http.Response response =
          await http.put(url, body: jsonEncode(isfavorite));
      if (response.statusCode >= 400) {
        isfavorite = oldStatus;
        notifyListeners();
      }
    } catch (e) {
      isfavorite = oldStatus;
      notifyListeners();
    }
  }
}
