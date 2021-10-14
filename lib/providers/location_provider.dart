
import 'package:location/location.dart';
import 'package:flutter/widgets.dart';

class LocationProvider with ChangeNotifier{
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

}
 
