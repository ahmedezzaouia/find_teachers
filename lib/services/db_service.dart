import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:maroc_teachers/modals/conversation.dart';
import 'package:maroc_teachers/modals/education.dart';
import 'package:maroc_teachers/modals/message.dart';
import 'package:maroc_teachers/providers/teacher.dart';
import 'package:maroc_teachers/services/cloud_storage_service.dart';
import 'package:maroc_teachers/services/snackbar_service.dart';

class DbService {
  static DbService instance = DbService();
  final _db = Firestore.instance;
  String _userCollection = 'users';
  String _conversationCollection = 'Conversations';

  Stream<List<ConversationSnippet>> getConversationsSnippet(
      String _userUid, String _userSearch) {
    var ref = _db
        .collection(_userCollection)
        .document(_userUid)
        .collection(_conversationCollection)
        .where('name', isGreaterThanOrEqualTo: _userSearch)
        .where('name', isLessThan: _userSearch + 'z');
    ;
    return ref.snapshots().map((_snapshot) {
      return _snapshot.documents.map((_doc) {
        return ConversationSnippet.fromFirebase(_doc);
      }).toList();
    });
  }

  Stream<Timestamp> getUserLastSeen(String _userUid) {
    var _userRef = _db.collection(_userCollection).document(_userUid);
    return _userRef.snapshots().map((_snapshot) {
      var _userData = _snapshot.data;
      return _userData['userLastSeen'];
    });
  }

  Future<void> getConversationOrCreate(
    String _userUid,
    String _receiverID,
    Future _onSuccess(String _conversationID),
  ) async {
    // check if the users has the same uid
    if (_userUid == _receiverID) {
      print('the users has the same uid');
      throw HttpException('the users has the same uid');
    }

    var _userColllectionRef = _db
        .collection(_userCollection)
        .document(_userUid)
        .collection(_conversationCollection);
    var _refconver = _db.collection(_conversationCollection);

    //check if the conversation between users already exist
    var _receivDocSnap = await _userColllectionRef.document(_receiverID).get();
    var _receiverData = _receivDocSnap.data;
    try {
      if (_receiverData != null) {
        print('user is exist............');
        //get Conversation (user already exist )
        return _onSuccess(_receiverData['conversationID']);
      } else {
        print('create conversation............');
        // create conversation because the receiverUser doesn't exixt
        String conversationId =
            await createConversation(_userUid, _receiverID, _refconver);
        return _onSuccess(conversationId);
      }
    } catch (e) {
      print('error create or get the conversation due to :${e.toString()}');
    }
  }

  Stream<Conversation> getConversation(String conversationID) {
    print('conversatin string it worsk? $conversationID');
    var _ref = _db.collection(_conversationCollection).document(conversationID);

    return _ref.snapshots().map((_snapshot) {
      var data = _snapshot.data;
      print('check from Dbservice classe :${data.toString()}');
      return Conversation.fromFirebase(_snapshot);
    });
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

  Future<String> getUserImage(String _userUid) async {
    var _userRef = _db.collection(_userCollection).document(_userUid);
    var data = await _userRef.get();
    return data['image'];
  }

  Future<String> getUserName(String _userUid) async {
    var _userRef = _db.collection(_userCollection).document(_userUid);

    DocumentSnapshot userSnaphot = await _userRef.get();
    var userData = userSnaphot.data;
    return userData['name'];
  }

  Future<String> createConversation(
    String _userUid,
    String _receiverID,
    var _ref,
  ) async {
    var _conversationRef = _ref.document();
    await _conversationRef.setData(
      {
        'members': [_userUid, _receiverID],
        'ownerID': _userUid,
        'messages': [],
      },
    );
    return _conversationRef.documentID;
  }

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

  Future<void> sendMessage(
      String _conversationID, Message message, String _userUid) async {
    var _ref =
        _db.collection(_conversationCollection).document(_conversationID);
    String senderName = await getUserName(_userUid);
    await _ref.updateData(
      {
        'messages': FieldValue.arrayUnion(
          [
            {
              'content': message.content,
              'type': message.type,
              'senderID': message.senderID,
              'timestamp': DateTime.now(),
              'senderName': senderName,
            }
          ],
        ),
      },
    );
  }

  Future<void> updateUnSeenCountMessages(
    String _reciverID,
    String _currentUser,
  ) async {
    var _userRef = _db
        .collection(_userCollection)
        .document(_reciverID)
        .collection(_conversationCollection)
        .document(_currentUser);

    try {
      // get your conversationSnippet data from the receiver in his Conversations collection
      DocumentSnapshot userDocSnaphsot = await _userRef.get();
      int unseenCountFromDb = userDocSnaphsot['unSeenCount'];
      return _userRef.updateData({'unSeenCount': unseenCountFromDb + 1});
    } catch (e) {
      print(
          'error accured when updating the unseenCount Messages due to :${e.toString()}');
    }
  }

  Future<void> resetUnSeenCount(String _userUid, String _receiverID) async {
    var _userRef = _db
        .collection(_userCollection)
        .document(_userUid)
        .collection(_conversationCollection)
        .document(_receiverID);

    try {
      DocumentSnapshot userDocSnaphsot = await _userRef.get();
      int unseenCountFromDb = userDocSnaphsot['unSeenCount'];
      if (unseenCountFromDb > 0) {
        return _userRef.updateData({'unSeenCount': 0});
      }
    } catch (e) {
      print('unSeenCount can\'t reste due to :${e.toString()}');
    }
  }

  Future<void> updateLastMessageForTwoUsers(
    String currentID,
    String recipientID,
    Message message,
  ) async {
    try {
      var data = {
        'lastMessage': message.content,
        'type': message.type,
        'timestamp': message.timestamp,
      };
      await _db
          .collection(_userCollection)
          .document(currentID)
          .collection(_conversationCollection)
          .document(recipientID)
          .updateData(data);
      await _db
          .collection(_userCollection)
          .document(recipientID)
          .collection(_conversationCollection)
          .document(currentID)
          .updateData(data);
    } catch (e) {
      print('error update last message because :${e.toString()}');
    }
  }

  Future<void> updateUserLastSeen(String _userUid) {
    var _ref = _db.collection(_userCollection).document(_userUid);
    try {
      return _ref.updateData(
        {
          'userLastSeen': Timestamp.now(),
        },
      );
    } catch (e) {
      print('user can\'t update his last seen due to :${e.toString()}');
      return null;
    }
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
          .showSnackBarSuccess('You have successfully updated to database');
    } catch (e) {
      SnackBarServie.instance
          .showSnackBarError('error occurred during the operation!.');
      print(
          'error can\'t update user\'s data firestore becouse of :${e.toString()}');
    }
  }
}
