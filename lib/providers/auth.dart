import 'dart:convert';
import 'dart:async';

import 'package:jwt_decode/jwt_decode.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  Map<String,dynamic> _formData = {};

  Auth(
    this._formData
  );

  bool _justSignedUp = false;

  //Get information on signed up status
  bool get justSignedUp {
    return _justSignedUp;
  }

  void resetSignUpStatus() {
    _justSignedUp = false;
  }

  static Future<void> _setToken(token,refresh,expiryDate) async {
    final userData = json.encode({
      'token' : token,
      'refresh' : refresh,
      'expiryDate' : expiryDate!.toIso8601String()
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userData', userData);
  }

  Future<void> _authenticate(String email, String password) async {
    final url = Uri.parse('https://authapi.chrisbriant.uk/api/account/authenticate/');
    try {
      final res = await http.post(
        url, 
        body: json.encode({
        'email' : email,
        'password' : password,
        }),
        headers: {"Content-Type": "application/json"},
      );
      final responseData = json.decode(res.body);
      if(responseData['success'] != null) {
        if(!responseData['success']) {
          throw HttpException(responseData['message']);
        }
      } else {
        if(responseData['access'] != null) {
          String token = responseData['access'];
          String refresh = responseData['refresh'];
          DateTime? expiryDate = Jwt.getExpiryDate(token);
          await _setToken(token, refresh, expiryDate);
          notifyListeners();
        } else {
          throw HttpException('Something went wrong tying to log on.');
        }
      }
    } catch(err) {
      throw err;
    }
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();

    if(!prefs.containsKey('userData')) {
      return false;
    }

    final extractedUserData = json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    final DateTime expiryDate = DateTime.parse(extractedUserData['expiryDate'] as String);
    final String refresh = extractedUserData['refresh'] as String; 
    if(expiryDate.isBefore(DateTime.now())) {
      //Try refresh token
      final url = Uri.parse('https://authapi.chrisbriant.uk/api/account/refresh/');
      try {
        final res = await http.post(
          url, 
          body: json.encode({
            'refresh': refresh
          }),
          headers: {"Content-Type": "application/json"},
        );
        final responseData = json.decode(res.body);
        if(responseData['access'] != null) {
          //set the access token
          await _setToken(responseData['access'], refresh, expiryDate);
          return true;
        } else {
          return false;
        }
      } catch(err) {
        return false;
      }
    }
    return true;
  }


  Future<bool> signup(String email,String password,String passchk,String username) async {
    final url = Uri.parse('https://authapi.chrisbriant.uk/api/account/register/');
    try {
      final res = await http.post(
        url, 
        body: json.encode({
          'username' : username,
          'email' : email,
          'password' : password,
          'passchk' : passchk
        }),
        headers: {'Content-Type': 'application/json'},
      );
      final responseData = json.decode(res.body);
      if(!responseData['success']) {
        throw HttpException(responseData['message']);
      } else {
        //Sign up successfull
        _justSignedUp = true;
        return true;
      }
    } catch(err) {
      throw HttpException(err.toString());
    }
  }

  Future<void> signin(String email,String password) async {
    return _authenticate(email, password);
  }

  Future<void> signout() async {
    //Destroy the token if it exists
    final prefs = await SharedPreferences.getInstance();

    if(prefs.containsKey('userData')) {
      prefs.remove('userData');
    }
    notifyListeners();
  }



}