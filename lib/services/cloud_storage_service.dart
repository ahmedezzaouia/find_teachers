import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class CloudStorageService {
  FirebaseStorage _storage;
  StorageReference _baseRef;
  String _profileImages = 'Profile_images';
  String _postsImages = 'Post_images';

  static CloudStorageService instance = CloudStorageService();
  CloudStorageService() {
    _storage = FirebaseStorage.instance;
    _baseRef = _storage.ref();
  }

  Future<StorageTaskSnapshot> uplodeUserImage(
    String _userUid,
    File _image,
  ) {
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

  Future<StorageTaskSnapshot> uplodePostImage(
      String _userUid, File _image, String postId) {
    try {
      return _baseRef
          .child(_postsImages)
          .child(_userUid)
          .child('post_$postId.jpg')
          .putFile(_image)
          .onComplete;
    } catch (e) {
      print('image not uplode to cloude storage becouse :${e.toString()}');
      return null;
    }
  }

  Future removePostImage(String userUid, String postId) async {
    try {
      if (userUid.isNotEmpty && postId.isNotEmpty) {
        print(
            '------------removePostImage cloudeStorage @userUid=== $userUid  and postId @==== $postId');
        _baseRef
            .child(_postsImages)
            .child(userUid)
            .child('post_$postId.jpg')
            .delete();
      } else {
        print('----------removePostImage cannnot remove image');
      }
    } on Exception catch (e) {
      throw e;
    }
  }
}
