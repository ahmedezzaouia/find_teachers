import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:maroc_teachers/modals/education.dart';
import 'package:maroc_teachers/providers/teacher.dart';
import 'package:maroc_teachers/services/cloud_storage_service.dart';
import 'package:maroc_teachers/services/snackbar_service.dart';

class DbService {
  static DbService instance = DbService();
  final _db = Firestore.instance;
  String _userCollection = 'users';

  Future<void> createUserInDb(
      String _userUid, String name, String image, String email) async {
    var _ref = _db.collection(_userCollection);

    DocumentSnapshot _userdata = await _ref.document(_userUid).get();
    if (_userdata.data == null) {
      return _ref.document(_userUid).setData({
        'name': name,
        'image': image,
        'email': email,
        'phone': 'enter a phone number',
        'education': [],
      });
    } else {
      print(
          'this user already stored in firestore name:$name and uid:$_userUid');
      return;
    }
  }

  Stream<Map<String, dynamic>> getUserData(String _userUid) {
    var _ref = _db.collection(_userCollection);
    return _ref.document(_userUid).snapshots().map((_snapshot) {
      Teacher teacher = Teacher.fromFirebase(_snapshot);
      List _educationList = _snapshot.data['education'];

      if (_educationList != null) {
        _educationList = _educationList.map((item) {
          return Education(
            schoolOrUniversity: item['schoolOrUniversity'],
            diploma: item['diploma'],
            startYear: item['startYear'],
            endYear: item['endYear'],
          );
        }).toList();
      } else {
        _educationList = [];
      }

      return {
        'teacher': teacher,
        'education': _educationList,
      };
    });
  }

  Future<void> updateUserData(
    String _userUid,
    var _userdata,
    List<Education> _education,
    File _pickedImage,
  ) async {
    var _userRef = _db.collection(_userCollection).document(_userUid);
    List<Map<String, dynamic>> _educationList = [];
    String _imageUrl;

    _education.forEach((item) {
      var data = {
        'schoolOrUniversity': item.schoolOrUniversity,
        'diploma': item.diploma,
        'startYear': item.startYear,
        'endYear': item.endYear,
      };
      _educationList.add(data);
    });
    try {
      if (_pickedImage != null) {
        StorageTaskSnapshot result = await CloudStorageService.instance
            .uplodeUserImage(_userUid, _pickedImage);
        _imageUrl = await result.ref.getDownloadURL();
      } else {
        var data = await _userRef.get();
        _imageUrl = data['image'];
      }

      await _userRef.updateData({
        'name': _userdata['name'],
        'phone': _userdata['phone'],
        'email': _userdata['email'],
        'about': _userdata['about'],
        'image': _imageUrl,
        'education': [],
      });

      await _userRef.updateData({
        'education': FieldValue.arrayUnion(
          _educationList,
        )
      });
      SnackBarServie.instance
          .showSnackBarSuccess('informations uplode successfully');
    } catch (e) {
      SnackBarServie.instance.showSnackBarError('error uplode.');
      print(
          'error can\'t update user\'s data firestore becouse of :${e.toString()}');
    }
  }
}
