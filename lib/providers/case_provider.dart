import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class CaseProvider with ChangeNotifier {
  static const String BASEURL = 'https://petdetectivebackend.chrisbriant.uk/api';
  List<int> _petRequests;

  CaseProvider (
    this._petRequests
  );

  // addToForm(String key,dynamic val) {
  //   _formData[key] = val;
  //   notifyListeners();
  // }

  // dynamic getFormValue(String key) {
  //   return _formData[key];
  // }

  Future<bool> makeRequest(petId,description) async {
    final url = Uri.parse('$BASEURL/pets/makerequest/');
    Map<String,String> _headers;
    try {
      _headers = await _getHeaders();
      print(_headers);
    } catch(err) {
      print(err);
      return false;
    }

    final res = await http.post(
      url, 
      body: json.encode({
      'pet_id' : petId,
      'description' : description,
      }),
      headers: _headers,
    );
    if(res.statusCode == 201) {
      _petRequests.add(petId);
      notifyListeners();
      return true;
    }
    throw HttpException('Something went wrong making the request');
    
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();

    if(prefs.containsKey('userData')) {
      Map<String, String> _headers = {
        'Authorization' : 'Bearer ${json.decode(prefs.get('userData') as String)['token']}',
        "Content-Type": "application/json"
      };
      return _headers;
    } else {
      throw Exception('Failed to retrieve headers.');
    }
  }

  List<int> get getPetRequests {
    return _petRequests;
  }

}