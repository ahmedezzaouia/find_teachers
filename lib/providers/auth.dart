import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:maroc_teachers/http_exceptions/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  String _userId;
  DateTime _expiryDate;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

//authenticat method
  Future<void> _authenticate(
      String urlSegment, String email, String password) async {
    try {
      final url =
          'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyADYq2fSjdf9j2oeBHum5lm4mcvcgGmXXw';

      http.Response response = await http.post(
        url,
        body: jsonEncode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      var responseData = jsonDecode(response.body);
      print(responseData);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      autoLogOut();

      notifyListeners();

      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString(
        'userdata',
        jsonEncode(
          {
            'token': _token,
            'userId': _userId,
            'expireyDate': _expiryDate.toIso8601String(),
          },
        ),
      );
    } catch (error) {
      throw error;
    }
  }

//register method
  Future<void> signUp(String email, String password) async {
    await _authenticate('signUp', email, password);
  }

// login method
  Future<void> login(String email, String password) async {
    await _authenticate('signInWithPassword', email, password);
  }

  //log out method
  Future<void> logOut() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    notifyListeners();
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences != null) {
      preferences.clear();
    }
  }

  //auto log out method
  void autoLogOut() {
    print('start time to auto log out...');
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;

    print(timeToExpiry);
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    _authTimer = Timer(Duration(seconds: timeToExpiry), logOut);
  }

  // auto login method
  Future<void> tryAutoLogin() async {
    print('try to auto loging...');

    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (!preferences.containsKey('userdata')) {
      return;
    }
    final extractedUserData =
        jsonDecode(preferences.getString('userdata')) as Map<String, Object>;
    final expiryData = DateTime.parse(extractedUserData['expireyDate']);

    if (expiryData.isBefore(DateTime.now())) {
      return;
    }
    print(extractedUserData);
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = DateTime.parse(extractedUserData['expireyDate']);
    notifyListeners();

    autoLogOut();
  }
}
