import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class CloudStorageService {
  FirebaseStorage _storage;
  StorageReference _baseRef;
  String _profileImages = 'Profile_images';

  static CloudStorageService instance = CloudStorageService();
  CloudStorageService() {
    _storage = FirebaseStorage.instance;
    _baseRef = _storage.ref();
  }

  Future<StorageTaskSnapshot> uplodeUserImage(String _userUid, File _image) {
    try {
      return _baseRef
          .child(_profileImages)
          .child(_userUid)
          .putFile(_image)
          .onComplete;
    } catch (e) {
      print('image not uplode to cloude storage becouse :${e.toString()}');
      return null;
    }
  }

  Future<StorageTaskSnapshot> uplodeMediaMessage(String _userUid, File _image) {
    String timestamp = DateTime.now().toString();
    String fileName = basename(_image.path);
    fileName += '$timestamp';
    try {
      return _baseRef
          .child('messages')
          .child(_userUid)
          .child('images')
          .child(fileName)
          .putFile(_image)
          .onComplete;
    } catch (e) {
      print(
          'image message not uploded to the cloudestorage due to :${e.toString()}');
      return null;
    }
  }
}
