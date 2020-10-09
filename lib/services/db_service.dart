import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:maroc_teachers/modals/comment.dart';
import 'package:maroc_teachers/modals/conversation.dart';
import 'package:maroc_teachers/modals/education.dart';
import 'package:maroc_teachers/modals/message.dart';
import 'package:maroc_teachers/modals/post.dart';
import 'package:maroc_teachers/providers/teacher.dart';
import 'package:maroc_teachers/services/cloud_storage_service.dart';
import 'package:maroc_teachers/services/snackbar_service.dart';
import 'package:maroc_teachers/widgets/search_item.dart';
import 'package:maroc_teachers/modals/notification.dart';

class DbService {
  static DbService instance = DbService();
  final _db = Firestore.instance;
  String _userCollection = 'users';
  String _conversationCollection = 'Conversations';
  String _postCollection = 'posts';
  String _followingRef = 'following';
  String _followersRef = 'followers';
  String _commentsRef = 'comments';
  String _notificationRef = 'notifications';

  Future<FirebaseUser> getCurrentUser() {
    return FirebaseAuth.instance.currentUser();
  }

  Stream<List<ConversationSnippet>> getConversationsSnippet(
      String _userUid, String _userSearch) {
    var ref = _db
        .collection(_userCollection)
        .document(_userUid)
        .collection(_conversationCollection)
        .where('name', isGreaterThanOrEqualTo: _userSearch)
        .where('name', isLessThan: _userSearch + 'z');

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

  Stream<Teacher> getUserData(String _userUid) {
    var _ref = _db.collection(_userCollection).document(_userUid);

    return _ref.snapshots().map((_snapshot) => Teacher.fromFirebase(_snapshot));
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
        'name': name.toLowerCase(),
        'image': image,
        'email': email,
        'phone': 'enter a phone number',
        'location': 'enter an location'
        // 'notificationCount': 0,
        // 'education': [],
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

  //TODO you have to fix this function later
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

  Stream<int> getPostsCount(String _userUid) {
    var _refPosts = _db
        .collection(_postCollection)
        .document(_userUid)
        .collection('userPosts');

    return _refPosts.snapshots().map((_snap) {
      return _snap.documents.length;
    });
  }

  Future<int> getFollowingsCount(String _userUid) {
    var _refFollowings = _db
        .collection(_followingRef)
        .document(_userUid)
        .collection('userFollowing');
    return _refFollowings.getDocuments().then((snap) => snap.documents.length);
  }

  Future<int> getFollowersCount(String _userUid) {
    var _refFollowers = _db
        .collection(_followersRef)
        .document(_userUid)
        .collection('userFollowers');
    return _refFollowers.getDocuments().then((_snap) => _snap.documents.length);
  }

  Future createPost(Post post) {
    try {
      var _ref = _db
          .collection(_postCollection)
          .document(post.ownerId)
          .collection('userPosts')
          .document(post.postId);

      return _ref.setData(
        {
          'postId': post.postId,
          'ownerId': post.ownerId,
          'username': post.username,
          'timestamp': post.timestamp,
          'userJob': 'Teacher',
          'description': post.description,
          'mediaUrl': post.mediaUrl,
          'likes': post.likes,
          // 'profileImage': post.profileImage,
        },
      );
    } on Exception catch (e) {
      print(
          'error accured while create post to database Due To : ${e.toString()}');
      return null;
    }
  }

  Future removePost({String postId, String userUId}) {
    try {
      var _ref = _db
          .collection(_postCollection)
          .document(userUId)
          .collection('userPosts')
          .document(postId);
      return _ref.delete();
    } on Exception catch (e) {
      throw e;
    }
  }

  Stream<List<Post>> getUserPosts(String _userUid) {
    var _ref = _db
        .collection(_postCollection)
        .document(_userUid)
        .collection('userPosts');

    return _ref.snapshots().map((query) {
      return query.documents.map(
        (_doc) {
          return Post.fromFireBase(_doc);
        },
      ).toList();
    });
  }

  Stream searchForUsers(String _userNameSearch) {
    print('form db _seachname =$_userNameSearch');
    var ref = _db
        .collection(_userCollection)
        .where('name', isGreaterThanOrEqualTo: _userNameSearch)
        .where('name', isLessThan: _userNameSearch + 'z');

    return ref.snapshots().map((_snapshot) {
      return _snapshot.documents.map((_doc) {
        return SearchItem(
          userName: _doc['name'],
          userImage: _doc['image'],
          userId: _doc.documentID,
        );
      }).toList();
    });
  }

  Future likePost({String postOwnerID, String postId, String likedByUser}) {
    try {
      var _ref = _db
          .collection(_postCollection)
          .document(postOwnerID)
          .collection('userPosts')
          .document(postId);

      return _ref.updateData({
        'likes': FieldValue.arrayUnion(
          [
            likedByUser,
          ],
        )
      });
    } on Exception catch (e) {
      print(
          '<<<<<<<<<*Error accured whene you liking post :${e.toString()}*>>>>>>>>');
      return null;
    }
  }

  Future unLikePost({String postOwnerID, String postId, String likedByUser}) {
    try {
      var _ref = _db
          .collection(_postCollection)
          .document(postOwnerID)
          .collection('userPosts')
          .document(postId);

      return _ref.updateData({
        'likes': FieldValue.arrayRemove(
          [
            likedByUser,
          ],
        )
      });
    } on Exception catch (e) {
      print(
          '<<<<<<<<<*Error accured whene you Unliking post :${e.toString()}*>>>>>>>>');
      return null;
    }
  }

  followUser(String _userUid, String _followingId) {
    try {
      var _followingReference = _db
          .collection(_followingRef)
          .document(_userUid)
          .collection('userFollowing');

      var _followersReference = _db
          .collection(_followersRef)
          .document(_followingId)
          .collection('userFollowers');

      _followingReference.document(_followingId).setData({});
      _followersReference.document(_userUid).setData({});
    } on Exception catch (e) {
      throw e;
    }
  }

  unFollowUser(String _userUid, String _followingId) {
    try {
      var _followingReference = _db
          .collection(_followingRef)
          .document(_userUid)
          .collection('userFollowing');

      var _followersReference = _db
          .collection(_followersRef)
          .document(_followingId)
          .collection('userFollowers');

      _followingReference.document(_followingId).delete();

      _followersReference.document(_userUid).delete();
    } on Exception catch (e) {
      throw e;
    }
  }

  Future<bool> isFollowing(String _userUid, String _followingId) async {
    var _followingReference = _db
        .collection(_followingRef)
        .document(_userUid)
        .collection('userFollowing')
        .document(_followingId);

    var doc = await _followingReference.get();
    return doc.exists;
  }

  Future addComment({Comment comment}) {
    try {
      var _ref = _db
          .collection(_commentsRef)
          .document(comment.postId)
          .collection(_commentsRef);

      return _ref.add(
        {
          'avatarUrl': comment.avatarUrl,
          'username': comment.username,
          'userId': comment.userId,
          'comment': comment.commentText,
          'postOwner': comment.postOwner,
          'postId': comment.postId,
          'timestamp': Timestamp.now(),
        },
      );
    } on Exception catch (error) {
      throw error;
    }
  }

  Stream<List<Comment>> getPostComments({String postId}) {
    try {
      var _ref = _db
          .collection(_commentsRef)
          .document(postId)
          .collection(_commentsRef)
          .orderBy('timestamp');

      return _ref.snapshots().map((_snapshot) {
        return _snapshot.documents.map(
          (doc) {
            return Comment.fromFirebase(doc);
          },
        ).toList();
      });
    } on Exception catch (error) {
      throw error;
    }
  }

  Future removeComment({String postId, String commentId}) {
    print('comment id:$commentId');
    print('post id Is :$postId');
    var _ref = _db
        .collection(_commentsRef)
        .document(postId)
        .collection(_commentsRef)
        .document(commentId);
    return _ref.delete();
  }

  Future sendNotificationLikes(NotificationFeed notification) {
    try {
      var _ref = _db
          .collection(_notificationRef)
          .document(notification.postOwner)
          .collection(_notificationRef)
          .document(notification.postId);
      return _ref.setData(
        {
          'username': notification.username,
          'userId': notification.userId,
          'avatarImg': notification.avatarImg,
          'postId': notification.postId,
          'postImage': notification.postImage,
          'timestamp': Timestamp.now(),
          'type': 'like',
        },
      );
    } on Exception catch (e) {
      throw e;
    }
  }

  Future removeNotificationLikes({String postOwner, String postId}) {
    var _ref = _db
        .collection(_notificationRef)
        .document(postOwner)
        .collection(_notificationRef)
        .document(postId);

    return _ref.delete();
  }

  Future sendNotificationComment(NotificationFeed notification) {
    try {
      var _ref = _db
          .collection(_notificationRef)
          .document(notification.postOwner)
          .collection(_notificationRef);
      return _ref.add(
        {
          'username': notification.username,
          'userId': notification.userId,
          'avatarImg': notification.avatarImg,
          'postId': notification.postId,
          'postImage': notification.postImage,
          'timestamp': Timestamp.now(),
          'comment': notification.comment,
          'type': 'comment',
        },
      );
    } on Exception catch (e) {
      throw e;
    }
  }

  Future sendNotificationFollow(
      {NotificationFeed notification, String followedUser}) {
    try {
      var _ref = _db
          .collection(_notificationRef)
          .document(followedUser)
          .collection(_notificationRef);
      return _ref.add(
        {
          'username': notification.username,
          'userId': notification.userId,
          'avatarImg': notification.avatarImg,
          'timestamp': Timestamp.now(),
          'type': 'follow',
        },
      );
    } on Exception catch (e) {
      throw e;
    }
  }

  Future removePostNotifications(String userUid, String postId) async {
    print('removePostNotifications :::: postID ====$postId');
    print('removePostNotifications :::: userUid ====$userUid');
    try {
      var _ref = await _db
          .collection(_notificationRef)
          .document(userUid)
          .collection(_notificationRef)
          .where('postId', isEqualTo: postId)
          .getDocuments();

      for (var doc in _ref.documents) {
        if (doc.exists) {
          doc.reference.delete();
        }
      }
      // return _ref.documents.map((doc) {
      //   if (doc.exists) {
      //     return doc.reference.delete();
      //   }
      // });
    } on Exception catch (e) {
      throw e;
    }
  }

  Future removePostComments(String postId) async {
    print('removePostComments :::: postId ====$postId');
    try {
      var _ref = await _db
          .collection(_commentsRef)
          .document(postId)
          .collection(_commentsRef)
          .getDocuments();

      for (var doc in _ref.documents) {
        if (doc.exists) {
          doc.reference.delete();
        }
      }

      return _ref.documents.map((doc) {
        if (doc.exists) {
          return doc.reference.delete();
        }
      });
    } on Exception catch (e) {
      throw e;
    }
  }

  Stream<List<NotificationFeed>> getNotificationFeed({String userUid}) {
    var _ref = _db
        .collection(_notificationRef)
        .document(userUid)
        .collection(_notificationRef)
        .orderBy('timestamp', descending: true);

    return _ref.snapshots().map(
      (_snap) {
        return _snap.documents
            .map((_doc) => NotificationFeed.fromFirebase(_doc))
            .toList();
      },
    );
  }

  Future addNotificationCount(String userId) async {
    var _ref = _db.collection(_userCollection).document(userId);
    return _ref.updateData({'notificationCount': FieldValue.increment(1)});
  }

  Stream<int> getUserNotificationsCount({String userId}) {
    var _ref = _db.collection(_userCollection).document(userId);
    return _ref.snapshots().map((snap) {
      return snap['notificationCount'];
    });
  }

  Future resetNotificationCount(String _userUid) {
    var _ref = _db.collection(_userCollection).document(_userUid);

    return _ref.updateData({'notificationCount': 0});
  }

  Future<List<Post>> getPostsFromFollowings(String _userID) async {
    List<Post> timeLinePosts = [];

    var _followings = await _db
        .collection(_followingRef)
        .document(_userID)
        .collection('userFollowing')
        .getDocuments();

    for (var following in _followings.documents) {
      // String followingId = following.documentID;

      var followingPosts = await _db
          .collection(_postCollection)
          .document(following.documentID)
          .collection('userPosts')
          .getDocuments();

      for (var _doc in followingPosts.documents) {
        timeLinePosts.add(Post.fromFireBase(_doc));
      }
    }

    timeLinePosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return timeLinePosts;
  }

  Future<void> updateUserProfileData({
    String userUid,
    String newName,
    String newLocation,
    String newDesctiption,
    String imageProfile,
  }) async {
    try {
      var _ref = _db.collection(_userCollection).document(userUid);

      if (newName.isNotEmpty) {
        _ref.updateData({'name': newName});
      }
      if (newLocation.isNotEmpty) {
        _ref.updateData({'location': newLocation});
      }
      if (newDesctiption.isNotEmpty) {
        _ref.updateData({'about': newDesctiption});
      }
      if (imageProfile.isNotEmpty) {
        _ref.updateData({'image': imageProfile});
      }
    } on Exception catch (e) {
      throw e;
    }
  }
}
