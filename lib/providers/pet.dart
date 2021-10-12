import 'dart:convert';
//import 'dart:async';

//import 'package:jwt_decode/jwt_decode.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

//import '../models/http_exception.dart';

class Pet with ChangeNotifier {
  static const String BASEURL = 'https://petdetectivebackend.chrisbriant.uk/api'; 

  Map<String,dynamic> _formData = {};

  Pet(
    this._formData
  );

  addToForm(String key,dynamic val) {
    _formData[key] = val;
    notifyListeners();
  }

  dynamic getFormValue(String key) {
    return _formData[key];
  }

  Future<bool> addPet(String name,String animal,String description,String lastSeen,String picture,String lat,String lng) async {
    Map<String,String> _headers;

    try {
      _headers = await _getHeaders();
      print(_headers);
    } catch(err) {
      print(err);
      return false;
    }
    
    var request = http.MultipartRequest('POST', Uri.parse('$BASEURL/pets/addpet/'));
    request.headers.addAll(_headers);
    request.files.add(
      await http.MultipartFile.fromPath(
        'picture',
        _formData['picture']
      )
    );
    // request.fields['name'] = _formData['name'];
    // print(this._formData['name']);
    // request.fields['description'] = _formData['description'];
    // request.fields['lastSeen'] = _formData['lastSeen'];
    // request.fields['animal'] = _formData['animal'];
    // request.fields['lat'] = '52.397532'; 
    // request.fields['lng'] = '-1.997979';

    request.fields['name'] = name;
    request.fields['description'] = description;
    print(description);
    request.fields['lastSeen'] = lastSeen;
    request.fields['animal'] = animal;
    request.fields['lat'] = lat; 
    request.fields['lng'] = lng;
    var _res = await request.send();
    //String _response = json.decode(_res.body);
    print(_res.statusCode);
    return false;
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();

    if(prefs.containsKey('userData')) {
      Map<String, String> _headers = {'Authorization' : 'Bearer ${json.decode(prefs.get('userData') as String)['token']}'};
      return _headers;
    } else {
      throw Exception('Failed to retrieve headers.');
    }
  }

}