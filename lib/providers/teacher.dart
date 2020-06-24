import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
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
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String userId = user.uid;
    final url =
        'https://findteachers-e06f1.firebaseio.com/favorites/$userId/$id.json';
    bool oldStatus = isfavorite;
    isfavorite = !isfavorite;
    notifyListeners();
    try {
      http.Response response =
          await http.put(url, body: jsonEncode(isfavorite));
      print(response.body);
      if (response.statusCode >= 400) {
        isfavorite = oldStatus;
        notifyListeners();
      }

      if (isfavorite == false) {
        await http.delete(url);
      }
    } catch (e) {
      isfavorite = oldStatus;
      notifyListeners();
    }
  }
}
