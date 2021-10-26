
import 'dart:convert';
import 'package:location/location.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './api_provider.dart';


class LocationProvider extends ApiProvider with ChangeNotifier{
  Location _location = new Location();
  late LocationData _locationData;
  bool _locationLoaded = false;
  bool permissionExists =  false;
  bool serviceEnabled = false;
  double? latitude;
  double? longitude;

  Future<dynamic> _initLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    return await _location.getLocation();
  }

  Future<LocationData> getLocationData() async {

    if(!_locationLoaded) {
      _locationData = await _initLocation();
      //Add Location listener
      _location.onLocationChanged.listen((LocationData currLoc) {
        // Use current location
        _locationData = currLoc;
       });
      _locationLoaded = true;
      latitude = _locationData.latitude;
      longitude = _locationData.longitude;
      notifyListeners();
      return _locationData;
    } else {
      return _locationData;
    }
  }

  void setLocationData (double lat, double lng) {
    latitude = lat;
    longitude = lng;
    notifyListeners();
  }

  LocationData get location {
    print(_locationData.latitude);
    print(_locationData.longitude);
    return _locationData;
  }

  double? get lat {
    return latitude;
  }

  double? get lng {
    return longitude;
  }

  bool get loaded {
    return _locationLoaded;
  }

  Future<bool> get isLocationSet async {
    final _prefs = await SharedPreferences.getInstance();
    

    print('Getting Location Set');
    if(_prefs.containsKey('locationData')) {
      print('exists');
      Map<String,dynamic> _locationData = json.decode(_prefs.get('locationData') as String);
      print(_prefs.get('locationData'));
      //_prefs.remove('locationData');
      return true;
    }
    return false;
  } 

  Future<void> setMyLocation(lat,lng) async {
    final _prefs = await SharedPreferences.getInstance();
    
    final _newLocationData = json.encode(
      {
        'lat' : lat,
        'lng' : lng
      }
    );
    print('Setting Location');
    _prefs.setString('locationData', _newLocationData);

    //Set in database
    final uri = Uri.parse('${ApiProvider.BASEURL}/pets/addlocation/');

    Map<String,String> _headers;
    try {
      _headers = await getHeadersJsonWithAuth();
    } catch(err) {
      print(err);
      return null;
    }

    var res = await http.post(
      uri,
      body: json.encode({
        'lat': lat,
        'lng': lng
      }),
      headers: _headers
    );

    print(res.statusCode);

    if(res.statusCode != 201) {
      throw HttpException('Couldn\'t set location on database.');
    }
  }


  Future<Map<String,dynamic>?> getMyLocation() async {
    final _prefs = await SharedPreferences.getInstance();

    if(_prefs.containsKey('locationData')) {
      Map<String,dynamic> _locationData = json.decode(_prefs.get('locationData') as String);
      return _locationData;
    } else {
      return null;
    }
  }

}
 
