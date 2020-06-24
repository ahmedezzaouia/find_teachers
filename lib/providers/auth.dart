import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:maroc_teachers/http_exceptions/http_exception.dart';

class Auth with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn = GoogleSignIn();
  FacebookLogin facebookLogin = FacebookLogin();

  String _userId;
  String get userId {
    return _userId;
  }

//register method
  Future<void> signUp(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

// login method
  Future<void> login(String email, String password) async {
    print('email : $email');
    print('password : $password');
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  //log out method
  Future logOut() async {
    await _auth.signOut();
    await googleSignIn.signOut();
    await facebookLogin.logOut();
    notifyListeners();
  }

  //Sign With Google
  Future signWithGoole() async {
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    if (googleSignInAuthentication.accessToken != null) {
      AuthResult result = await _auth.signInWithCredential(credential);
      FirebaseUser user = result.user;
      assert(!user.isAnonymous);
      assert(user.email != null);
      assert(user.displayName != null);
      assert(await user.getIdToken() != null);
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      notifyListeners();

      print('username :${user.displayName}  userUid : ${user.uid}');
    }
  }

//sign with Facebook
  Future signInWithFacebook() async {
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
        } catch (error) {
          print('login error :${error.toString()}');
        }
        break;
    }

    return null;
  }
}
