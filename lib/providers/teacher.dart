import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class Teacher with ChangeNotifier {
  final String id;
  final String creatorID;
  final String teaherName;
  final String phoneNumber;
  final String teacherDescription;
  final String teacherImageUrl;
  final String teachingSubject;
  final String teacherEmaill;
  bool isfavorite;

  Teacher({
    @required this.teaherName,
    @required this.id,
    @required this.teacherDescription,
    @required this.teacherImageUrl,
    @required this.teachingSubject,
    this.phoneNumber,
    this.teacherEmaill,
    this.creatorID,
    this.isfavorite = false,
  });

  Future<void> toggleFavorite(String _id) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String userId = user.uid;
    final url =
        'https://findteachers-e06f1.firebaseio.com/favorites/$userId/$_id.json';
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

  factory Teacher.fromFirebase(DocumentSnapshot _snapshot) {
    Map<String, dynamic> data = _snapshot.data;

    return Teacher(
      id: _snapshot.documentID,
      teaherName: data['name'],
      teacherDescription: data['about'] == null ? '' : data['about'],
      teacherImageUrl: data['image'],
      teachingSubject: null,
      isfavorite: false,
      phoneNumber: data['phone'],
      teacherEmaill: data['email'],
    );
  }
}
