import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import '../providers/api_provider.dart';

class CaseProvider extends ApiProvider with ChangeNotifier {
  static const String BASEURL = 'https://petdetectivebackend.chrisbriant.uk/api';
  List<int> _petRequests;
  List<DetectiveRequest> _detectiveRequests;
  List<int> _petCases;


  CaseProvider (
    this._petRequests,
    this._detectiveRequests,
    this._petCases
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

  Future<List<DetectiveRequest>> getRequestsByPetId(id) async {
    _detectiveRequests.clear();
    Map<String,String> _headers;
    try {
      _headers = await getHeadersJsonWithAuth();
      print(_headers);
    } catch(err) {
      print(err);
      return [];
    }

    var res = await http.get(
      Uri.parse('$BASEURL/pets/petrequests?pet_id=${id.toString()}'),
      headers: _headers
    );
    if(res.statusCode == 200) {
      final _responseData = json.decode(res.body);
      for(var _pRequest in _responseData) {
        print(_pRequest);
        print(_pRequest['detective']['id']);
        print(DateTime.parse(_pRequest['date_added']));
        _detectiveRequests.add(
          DetectiveRequest(
            id: _pRequest['id'],
            accepted: _pRequest['accepted'],
            description: _pRequest['description'],
            dateAdded: DateTime.parse(_pRequest['date_added']),
            detective: Detective(
              id: _pRequest['detective']['id'], 
              name: _pRequest['detective']['name']
            )
          )
        );
      }
      
    }
    return _detectiveRequests;
  }

}

class Detective {
  int id;
  String name;
  double? lat;
  double? lng;

  Detective({
    required this.id,
    required this.name,
    this.lat,
    this.lng,
  });
}

class DetectiveRequest {
  int id;
  bool accepted;
  String description;
  DateTime dateAdded;
  Detective detective;

  DetectiveRequest({
    required this.id,
    required this.accepted,
    required this.description,
    required this.dateAdded,
    required this.detective
  });
  
}