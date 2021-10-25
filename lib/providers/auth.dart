import 'dart:convert';
import 'dart:async';

import 'package:jwt_decode/jwt_decode.dart';
import 'package:flutter/widgets.dart';
import 'package:petdetective/providers/api_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Auth extends ApiProvider with ChangeNotifier {
  static const String BASEURL = 'https://petdetectivebackend.chrisbriant.uk/api'; 

  Map<String,dynamic> _formData = {};
  int userId;
  UserProfile? _userProfile;

  Auth(
    this._formData,
    [this.userId = 0]
  );

  addToForm(String key,dynamic val) {
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

  // void _setSessionData(id) {
  //   userId = id;
  // }

  static Future<void> _setToken(token,refresh,expiryDate,isDetective,id) async {
    final userData = json.encode({
      'token' : token,
      'refresh' : refresh,
      'expiryDate' : expiryDate!.toIso8601String(),
      'isDetective' : isDetective,
      'id' : id
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userData', userData);
  }

  Future<void> _authenticate(String email, String password) async {
    final url = Uri.parse('$BASEURL/account/authenticate/');
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
          Map<String, dynamic> payload = Jwt.parseJwt(token);
          //TODO - Get the user ID from the payload and store
          await _setToken(token, refresh, expiryDate, payload['is_detective'],payload['user_id']);
          //_setSessionData(payload['user_id']);
          notifyListeners();
        } else {
          throw HttpException('Something went wrong tying to log on.');
        }
      }
    } catch(err) {
      throw err;
    }
    notifyListeners();
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();

    if(!prefs.containsKey('userData')) {
      return false;
    }

    final extractedUserData = json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    final DateTime expiryDate = DateTime.parse(extractedUserData['expiryDate'] as String);
    print(extractedUserData);
    //Two lines of code below need testing
    final int id = extractedUserData['id'] as int;
    final bool isDetective = extractedUserData['isDetective'] as bool;
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
          await _setToken(responseData['access'], refresh, expiryDate,isDetective,id);
          //_setSessionData(id);
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
      prefs.remove('userData');
    }
    notifyListeners();
  }

  Future<bool> isDetective() async {
    //Destroy the token if it exists
    final prefs = await SharedPreferences.getInstance();

    if(prefs.containsKey('userData')) {
      Map<String,dynamic> _userData = json.decode(prefs.get('userData') as String);

      if(_userData['isDetective'] == null) {
        return false; 
      } else {
        return _userData['isDetective']; 
      } 
    } else {
      print('There is no user data');
    }
    return false;
  }

  Future<int> get id async {
    final prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey('userData')) {
      Map<String,dynamic> _userData = json.decode(prefs.get('userData') as String);
      return _userData['id'];
    }
    throw Exception('Unable to retrieve user data.');
  }

  Future<UserProfile?> get myProfile async {
    final uri = Uri.parse('$BASEURL/account/myprofile');

    Map<String,String> _headers;
    try {
      _headers = await getHeadersJsonWithAuth();
    } catch(err) {
      print(err);
      return null;
    }

    final res = await http.get(
      uri,
      headers: _headers
    );

    if(res.statusCode == 200) {
      final _responseData = json.decode(res.body);

      double? _lat;
      double? _lng;

      print('User profile');
      print(_responseData);

      if(_responseData['location'] != null) {
        print('Adding lat lng');
          _lat = _responseData['location']['lat'];
          _lng = _responseData['location']['lng'];
      }

      _userProfile = UserProfile(
        id: _responseData['id'], 
        name: _responseData['name'], 
        isDetective: _responseData['is_detective'], 
        requestCount: _responseData['request_count'], 
        caseCount: _responseData['case_count'],
        lat: _lat,
        lng: _lng
      );
      return _userProfile;
    }

    throw HttpException('Something went wrong retrieving the user profile.');

    
  }

}


class UserProfile {
  final int id;
  final String name;
  final bool isDetective;
  final double? lat;
  final double? lng;
  final int requestCount;
  final int caseCount;

  const UserProfile({
    required this.id,
    required this.name,
    required this.isDetective,
    this.lat,
    this.lng,
    required this.requestCount,
    required this.caseCount
  });

}