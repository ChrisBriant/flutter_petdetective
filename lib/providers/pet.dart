import 'dart:convert';
//import 'dart:async';

//import 'package:jwt_decode/jwt_decode.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../providers/api_provider.dart';

//import '../models/http_exception.dart';

class Pet extends ApiProvider with ChangeNotifier {
  static const String BASEURL = 'https://petdetectivebackend.chrisbriant.uk/api';
  
  List<MissingPet> pets = [];
  MissingPet? _selectedPet;  

  Map<String,dynamic> _formData = {};

  Pet(
    this._formData,
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

  void _addPets(responseData) {
    pets.clear();
    for(var item in responseData) {
      //Get the missing location of the pet
      List<dynamic> _locations = item['locations'];
      dynamic _missingLocation = _locations.firstWhere((element) => element['location_type'] == 'Missing Location');
      List<dynamic> _requestsIds = json.decode(item['requests_detective_id']);
      pets.add(MissingPet(
        name: item['name'],
        animal: item['animal'],
        id: item['id'],
        description: item['description'],
        lastSeen: item['last_seen'],
        lat: _missingLocation['lat'],
        lng: _missingLocation['lng'],
        imgUrl: ApiProvider.MEDIAURL + item['picture'],
        requestsIds: _requestsIds.cast<int>(),
        isCaseOpen: item['is_case_open'],
        status: item['status'],
        statusStr: item['status_str']      
      ));
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
    pets.clear();
    //http://127.0.0.1:8000/api/pets/petsnearme?lat=52.394800&lng=-2.003761&dist=2
    distance == null ? distance = 2 : distance = distance;
    if(lat == null || lng == null) {
      final _prefs = await SharedPreferences.getInstance();
      if(!_prefs.containsKey('locationData')) {
        return [];
      }
      Map<String,dynamic> _locationData = json.decode(_prefs.get('locationData') as String);
      lat = _locationData['lat'].toString();
      lng = _locationData['lng'].toString();
    }
    
    final url = Uri.parse('$BASEURL/pets/petsnearme?lat=$lat&lng=$lng&dist=$distance');
    final res = await http.get(url);
    if(res.statusCode == 200) {
      final responseData = json.decode(res.body);
      for(var item in responseData) {
        //Get the missing location of the pet
        List<dynamic> _locations = item['locations'];
        dynamic _missingLocation = _locations.firstWhere((element) => element['location_type'] == 'Missing Location');
        List<dynamic> _requestsIds = json.decode(item['requests_detective_id']);
        //List<String> _requestsIdsStr = item['requests_detective_id'];
        //List<int> _requestsIds = _requestsIdsStr.map(int.parse).toList();
        print('processing missing pet');
        pets.add(MissingPet(
                  name: item['name'],
                  animal: item['animal'],
                  id: item['id'],
                  description: item['description'],
                  lastSeen: item['last_seen'],
                  lat: _missingLocation['lat'],
                  lng: _missingLocation['lng'],
                  imgUrl: ApiProvider.MEDIAURL + item['picture'],
                  requestsIds: _requestsIds.cast<int>(),
                  isCaseOpen: item['is_case_open'],
                  status: item['status'],
                  statusStr: item['status_str']   
                ));
      }
      return pets;
    }
    return [];
  }

  Future<List<MissingPet>> getMyPets({String? lat,String? lng, int? distance}) async {
    pets.clear();
    Map<String,String> _headers;
    try {
      _headers = await getHeadersJsonWithAuth();
      print(_headers);
    } catch(err) {
      print(err);
      return [];
    }

    print('Getting Pets');
    print('$BASEURL/pets/mypets/');

    var res = await http.get(
      Uri.parse('$BASEURL/pets/mypets/'),
      headers: _headers
    );
    if(res.statusCode == 200) {
      _addPets(json.decode(res.body));
    }
    return pets;
  }

  MissingPet getPet(petId) {
    return pets.firstWhere((e) => e.id == petId );
  }

  set setSelectedPet(pet) {
    _selectedPet = pet;
  }

  MissingPet? get getSelectedPet {
    return _selectedPet;
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
    List<int> requestsIds;
    bool isCaseOpen;
    int status;
    String statusStr;

    MissingPet({
      required this.id,
      required this.name,
      required this.description,
      required this.lastSeen,
      required this.animal,
      required this.lat,
      required this.lng,
      required this.imgUrl,
      required this.requestsIds,
      required this.isCaseOpen,
      required this.status,
      required this.statusStr

    });

}