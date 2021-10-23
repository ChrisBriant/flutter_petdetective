import 'dart:convert';
import 'dart:async';
import 'dart:io';

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
  List<Case> _petCases;


  CaseProvider (
    this._petRequests,
    this._detectiveRequests,
    this._petCases
  );

  Future<bool> makeRequest(petId,description) async {
    final url = Uri.parse('$BASEURL/pets/makerequest/');
    Map<String,String> _headers;
    try {
      _headers = await _getHeaders();
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

  DetectiveRequest _createDetectiveRequest(data) {
    return DetectiveRequest(
      id: data['id'],
      accepted: data['accepted'],
      description: data['description'],
      dateAdded: DateTime.parse(data['date_added']),
      detective: Detective(
        id: data['detective']['id'], 
        name: data['detective']['name']
      )
    );
  }  

  Future<List<DetectiveRequest>> getRequestsByPetId(id) async {
    _detectiveRequests.clear();
    Map<String,String> _headers;
    try {
      _headers = await getHeadersJsonWithAuth();
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

  Future<List<Case>> getCases(id) async {
    _petCases.clear();
    var res = await http.get(
      Uri.parse('$BASEURL/pets/petcases?pet_id=${id.toString()}'),
      headers: await getHeadersJsonWithAuth()
    );
    print('PET CASES');
    print(res.statusCode);
    if(res.statusCode == 200) {
      final _responseData = json.decode(res.body);
      print(_responseData);
      for(var _pCase in _responseData) {
        _petCases.add(
          Case(
            id: _pCase['id'], 
            dateAdded: DateTime.parse(_pCase['date_added']),
            detective: Detective(
                          id: _pCase['detective']['id'], 
                          name: _pCase['detective']['name']
            )
          )
        );
      }
    }
    return _petCases;
  } 

  Future<void> acceptRequest(id) async {
    var res = await http.post(
      Uri.parse('$BASEURL/pets/acceptrequest/'),
      body: json.encode({'id': id}),
      headers: await getHeadersJsonWithAuth()
    );
    if(res.statusCode == 201) {
      notifyListeners();
      return;
    }
    //sleep(Duration(seconds: 5));
    throw HttpException('Something went wrong accepting the request.');
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

class Case {
  int id;
  DateTime dateAdded;
  Detective detective;

  Case({
    required this.id,
    required this.dateAdded,
    required this.detective
  });
}