import 'dart:convert';
import 'dart:async';

import 'package:jwt_decode/jwt_decode.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  static const String BASEURL = 'https://petdetectivebackend.chrisbriant.uk/api'; 

  Map<String,dynamic> _formData = {};

  Auth(
    this._formData
  );

  addToForm(String key,dynamic val) {
    print('Adding to form');
    _formData[key] = val;
    notifyListeners();
  }

  dynamic getFormValue(String key) {
    return _formData[key];
  }

  bool _justSignedUp = false;

  //Get information on signed up status
  bool get justSignedUp {
    return _justSignedUp;
  }

  void resetSignUpStatus() {
    _justSignedUp = false;
  }

  static Future<void> _setToken(token,refresh,expiryDate,isDetective) async {
    final userData = json.encode({
      'token' : token,
      'refresh' : refresh,
      'expiryDate' : expiryDate!.toIso8601String(),
      'isDetective' : isDetective
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userData', userData);
  }

  Future<void> _authenticate(String email, String password) async {
    final url = Uri.parse('$BASEURL/account/authenticate/');
    print(url);
    print(email);
    print(password);
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
          //TODO - The is detective attribute needs to be encoded into the token and then
          // to set the attribute on the token itself.
          await _setToken(token, refresh, expiryDate, false);
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
      print('I am not authenticated');
      return false;
    }

    final extractedUserData = json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    final DateTime expiryDate = DateTime.parse(extractedUserData['expiryDate'] as String);
    final String refresh = extractedUserData['refresh'] as String; 
    if(expiryDate.isBefore(DateTime.now())) {
      //Try refresh token
      final url = Uri.parse('$BASEURL/account/refresh/');
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
          await _setToken(responseData['access'], refresh, expiryDate,false);
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


  Future<bool> signup(String email,String password,String passchk,String username,bool isDetective) async {
    final url = Uri.parse('$BASEURL/account/register/');
    print('$BASEURL/account/register/');
    print(username);
    print(password);
    print(passchk);
    print(username);
    print(isDetective);
    try {
      final res = await http.post(
        url, 
        body: json.encode({
          'username' : username,
          'email' : email,
          'password' : password,
          'passchk' : passchk,
          'is_detective': isDetective
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
      print('I am supposed to destroy the token');
      prefs.remove('userData');
    }
    notifyListeners();
  }

  Future<bool> isDetective() async {
    //Destroy the token if it exists
    final prefs = await SharedPreferences.getInstance();

    if(prefs.containsKey('userData')) {
      Map<String,dynamic> _userData = json.decode(prefs.get('userData') as String);
      print(_userData['isDetective']);  
      return true;
    } else {
      print('There is no user data');
    }
    return false;
  }



}