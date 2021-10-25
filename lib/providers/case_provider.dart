import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:petdetective/providers/pet.dart';
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
    List<dynamic> _locations = data['pet']['locations'];
    dynamic _missingLocation = _locations.firstWhere((element) => element['location_type'] == 'Missing Location');
    List<dynamic> _requestsIds = json.decode(data['pet']['requests_detective_id']);
    return DetectiveRequest(
      id: data['id'],
      accepted: data['accepted'],
      description: data['description'],
      dateAdded: DateTime.parse(data['date_added']),
      detective: Detective(
        id: data['detective']['id'], 
        name: data['detective']['name']
      ),
      pet: MissingPet(
        id: data['pet']['id'], 
        name: data['pet']['name'], 
        description: data['pet']['description'], 
        lastSeen: data['pet']['last_seen'], 
        animal: data['pet']['animal'], 
        lat: _missingLocation['lat'], 
        lng: _missingLocation['lng'], 
        imgUrl: ApiProvider.MEDIAURL + data['pet']['picture'], 
        requestsIds: _requestsIds.cast<int>(), 
        isCaseOpen: data['pet']['is_case_open'],
        status: data['pet']['status'],
        statusStr: data['pet']['status_str']   
      )
    );
  }  

  Future<List<DetectiveRequest>> getRequests({id=0,byPet=true}) async {
    _detectiveRequests.clear();
    Map<String,String> _headers;
    try {
      _headers = await getHeadersJsonWithAuth();
    } catch(err) {
      print(err);
      return [];
    }

    Uri uri;

    if(byPet) {
      uri = Uri.parse('$BASEURL/pets/petrequests?pet_id=${id.toString()}');
    } else {
      uri = Uri.parse('$BASEURL/pets/myrequests?qstype=all');
    }

    var res = await http.get(
      uri,
      headers: _headers
    );
    if(res.statusCode == 200) {
      final _responseData = json.decode(res.body);
      for(var _pRequest in _responseData) {
        List<dynamic> _locations = _pRequest['pet']['locations'];
        dynamic _missingLocation = _locations.firstWhere((element) => element['location_type'] == 'Missing Location');
        List<dynamic> _requestsIds = json.decode(_pRequest['pet']['requests_detective_id']);
        _detectiveRequests.add(
          DetectiveRequest(
            id: _pRequest['id'],
            accepted: _pRequest['accepted'],
            description: _pRequest['description'],
            dateAdded: DateTime.parse(_pRequest['date_added']),
            detective: Detective(
              id: _pRequest['detective']['id'], 
              name: _pRequest['detective']['name']
            ),
            pet: MissingPet(
              id: _pRequest['pet']['id'], 
              name: _pRequest['pet']['name'], 
              description: _pRequest['pet']['description'], 
              lastSeen: _pRequest['pet']['last_seen'], 
              animal: _pRequest['pet']['animal'], 
              lat: _missingLocation['lat'], 
              lng: _missingLocation['lng'], 
              imgUrl: ApiProvider.MEDIAURL + _pRequest['pet']['picture'], 
              requestsIds: _requestsIds.cast<int>(), 
              isCaseOpen: _pRequest['pet']['is_case_open'],
              status: _pRequest['pet']['status'],
              statusStr: _pRequest['pet']['status_str']   
            )
          )
        );
      }
    }
    return _detectiveRequests;
  }

  Future<List<Case>> getCases({id=0,byPet=true}) async {
    Uri uri;
    byPet
    ? uri = Uri.parse('$BASEURL/pets/petcases?pet_id=${id.toString()}')
    : uri = Uri.parse('$BASEURL/pets/mycases');

    _petCases.clear();
    var res = await http.get(
      uri,
      headers: await getHeadersJsonWithAuth()
    );
    if(res.statusCode == 200) {
      final _responseData = json.decode(res.body);
      for(var _pCase in _responseData) {
        List<dynamic> _locations = _pCase['pet']['locations'];
        dynamic _missingLocation = _locations.firstWhere((element) => element['location_type'] == 'Missing Location');
        List<dynamic> _requestsIds = json.decode(_pCase['pet']['requests_detective_id']);
        _petCases.add(
          Case(
            id: _pCase['id'], 
            dateAdded: DateTime.parse(_pCase['date_added']),
            detective: Detective(
                          id: _pCase['detective']['id'], 
                          name: _pCase['detective']['name']
            ),
            pet: MissingPet(
              id: _pCase['pet']['id'], 
              name: _pCase['pet']['name'], 
              description: _pCase['pet']['description'], 
              lastSeen: _pCase['pet']['last_seen'], 
              animal: _pCase['pet']['animal'], 
              lat: _missingLocation['lat'], 
              lng: _missingLocation['lng'], 
              imgUrl: ApiProvider.MEDIAURL + _pCase['pet']['picture'], 
              requestsIds: _requestsIds.cast<int>(), 
              isCaseOpen: _pCase['pet']['is_case_open'],
              status: _pCase['pet']['status'],
              statusStr: _pCase['pet']['status_str']   
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
  MissingPet pet;

  DetectiveRequest({
    required this.id,
    required this.accepted,
    required this.description,
    required this.dateAdded,
    required this.detective,
    required this.pet
  });
  
}

class Case {
  int id;
  DateTime dateAdded;
  Detective detective;
  MissingPet pet;

  Case({
    required this.id,
    required this.dateAdded,
    required this.detective,
    required this.pet
  });
}