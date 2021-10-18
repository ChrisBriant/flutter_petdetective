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
  static const String MEDIAURL = 'https://petdetectivebackend.chrisbriant.uk';
  List<MissingPet> pets = [];  

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
    if(_res.statusCode == 201) {
      return true;
    } else {
      return false;
    }
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

  Future<List<MissingPet>> getMissingPets({String? lat,String? lng, int? distance}) async {
    //http://127.0.0.1:8000/api/pets/petsnearme?lat=52.394800&lng=-2.003761&dist=2
    distance == null ? distance = 2 : distance = distance;
    if(lat == null || lng == null) {
      final _prefs = await SharedPreferences.getInstance();
      Map<String,dynamic> _locationData = json.decode(_prefs.get('locationData') as String);
      lat = _locationData['lat'].toString();
      lng = _locationData['lng'].toString();
    }
    
    final url = Uri.parse('$BASEURL/pets/petsnearme?lat=$lat&lng=$lng&dist=$distance');
    final res = await http.get(url);
    if(res.statusCode == 200) {
      final responseData = json.decode(res.body);
      for(var item in responseData) {
        pets.add(MissingPet(
                  name: item['name'],
                  animal: item['animal'],
                  id: item['id'],
                  description: item['description'],
                  lastSeen: item['last_seen'],
                  lat: item['lat'],
                  lng: item['lng'],
                  imgUrl: MEDIAURL + item['picture']   
                ));
      }
      return pets;
    }
    return [];
  }

  MissingPet getPet(petId) {
    return pets.firstWhere((e) => e.id == petId );
  }

}

class MissingPet {
    int id;
    String name;
    String description;
    String lastSeen;
    String animal;
    double? lat; 
    double? lng;
    String imgUrl;

    MissingPet({
      required this.id,
      required this.name,
      required this.description,
      required this.lastSeen,
      required this.animal,
      required this.lat,
      required this.lng,
      required this.imgUrl
    });

}