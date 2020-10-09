import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:maroc_teachers/services/db_service.dart';

class AuthProvider with ChangeNotifier {
  static AuthProvider instence = AuthProvider();
  FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn = GoogleSignIn();
  FacebookLogin facebookLogin = FacebookLogin();

  FirebaseUser _user;
  // FirebaseUser get user {
  //   if (_user == null) {
  //     getCurrentUser();
  //     return _user;
  //   } else {
  //     return _user;
  //   }
  // }

  FirebaseUser get user => _user;
  void setUser(FirebaseUser _currentUser) {
    _user = _currentUser;
  }

//register method
  Future<void> signUp(
    String email,
    String password,
    Future<void> _onSucces(String _uid),
  ) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      _user = result.user;
      await _onSucces(_user.uid);
      await DbService.instance.updateUserLastSeen(_user.uid);
    } catch (e) {
      _user = null;

      print('register error :${e.toString()}');
    }
    notifyListeners();
  }

// login method
  Future<void> login(String email, String password) async {
    AuthResult result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    _user = result.user;
    await DbService.instance.updateUserLastSeen(_user.uid);

    notifyListeners();
  }

  //log out method
  Future logOut() async {
    await _auth.signOut();
    await googleSignIn.signOut();
    await facebookLogin.logOut();
    _user = null;
    notifyListeners();
  }

  //Sign With Google
  Future signWithGoole(
    Future<void> _onSucess(
      String _userUid,
      String name,
      String email,
      String image,
    ),
  ) async {
    try {
      GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken);
      if (googleSignInAuthentication.accessToken != null) {
        AuthResult result = await _auth.signInWithCredential(credential);
        FirebaseUser user = result.user;
        assert(!user.isAnonymous);
        assert(user.email != null);
        assert(user.displayName != null);
        assert(await user.getIdToken() != null);
        final FirebaseUser currentUser = await _auth.currentUser();
        assert(user.uid == currentUser.uid);
        _user = currentUser;
        notifyListeners();
        await _onSucess(
            _user.uid, _user.displayName, _user.email, _user.photoUrl);
        await DbService.instance.updateUserLastSeen(_user.uid);
      }
    } catch (e) {
      _user = null;
      print('google authenticate error :${e.toString()}');
      notifyListeners();
    }
  }

//sign with Facebook
  Future signInWithFacebook(
      Future<void> _onSucess(
    String _userUid,
    String name,
    String email,
    String image,
  )) async {
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.error:
        print("Error facebook login ");
        break;

      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser facebook login");
        break;

      case FacebookLoginStatus.loggedIn:
        print("LoggedIn to facebook account");

        try {
          AuthCredential credential = FacebookAuthProvider.getCredential(
            accessToken: result.accessToken.token,
          );
          AuthResult authResult = await _auth.signInWithCredential(credential);
          FirebaseUser user = authResult.user;
          assert(!user.isAnonymous);
          assert(user.email != null);
          assert(user.displayName != null);
          assert(await user.getIdToken() != null);
          _user = authResult.user;
          await _onSucess(
              _user.uid, _user.displayName, _user.email, _user.photoUrl);
          await DbService.instance.updateUserLastSeen(_user.uid);

          notifyListeners();
        } catch (error) {
          _user = null;
          print('facebook authenticate error :${error.toString()}');
          notifyListeners();
        }
        break;
    }

    return null;
  }

  // Future getAndSetCurrentUser() async {
  //   FirebaseUser currentUser = await _auth.currentUser();
  //   _user = currentUser;
  //   notifyListeners();
  // }
}
