import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import "package:latlong2/latlong.dart" as latLng;
import 'package:provider/provider.dart';

import '../providers/location_provider.dart';
import '../providers/pet.dart';
import '../providers/auth.dart';


class PetPersonMapScreen extends StatelessWidget {
  static String routeName = '/petpersonmapscreen';
  


  @override
  Widget build(BuildContext context) {
    final _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final _petProvider = Provider.of<Pet>(context, listen: false);
    final _auth = Provider.of<Auth>(context,listen: false);
    final Map<String,Object>? args = ModalRoute.of(context)!.settings.arguments as Map<String,Object>?;
    Object? _mapMode = args!['mode'];
    double _distFromBottom = MediaQuery.of(context).size.height * 0.10;
    //For centering map on first item found
    double? _centerLat = 0.0;
    double? _centerLng = 0.0;
    List<Marker> _markersList = [];

    Marker _getMarker(lat,lng) {
      print(lat);
      return Marker(
        width: 80.0,
        height: 80.0,
        point: latLng.LatLng(lat, lng),
        builder: (ctx) =>
        Container(
          child: Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 36.0,
          ),
        ),
      );

    }


    List<Marker> _getMarkers() {
      switch (_mapMode) {
        case 'single-pet':
          List<MissingPet> _petsFound = [];
          _petsFound.add(_petProvider.getPet(args['petId']));
          //Add first location
          if(_petsFound.length > 0) {
            print('Pet Found');
            print(_petsFound[0].lat);
            print(_petsFound[0].lng);
            _centerLat = _petsFound[0].lat;
            _centerLng = _petsFound[0].lng;
          }
          for(var _pet in _petsFound) {
            _markersList.add(_getMarker(_pet.lat,_pet.lng));
          }
          return _markersList;
        case 'single-person':
          //Future<Map<String,double>?> _locationData = 
          _locationProvider.getMyLocation().then(
            (location) {
              print(location);
              if(location != null) {
                _markersList.add(_getMarker(location['lat'],location['lng']));
              }
            }
          );
          // UserProfile? _userProfile = _auth.savedProfile;
          // _userProfile != null
          // ? _markersList.add(_getMarker(_userProfile.lat,_userProfile.lng))
          // : _markersList = [];
          return _markersList;
        default:
          return [];
      }
    }

    _getMarkers();

    latLng.LatLng _getCenterPoint() {
      latLng.LatLng _latLng;

      try {
       _latLng = latLng.LatLng(_markersList.first.point.latitude,_markersList.first.point.longitude);
      } catch(err) {
        print(err);
        _latLng  = latLng.LatLng(0,0); 
      }
      return _latLng;
    }


    return Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    //center: latLng.LatLng(52.39225792161001, -2.00660652485873),
                    center: _getCenterPoint(),
                    zoom: 13.0,
                    onTap: (pos,latLng) {}
                  ),
                  layers: [
                    TileLayerOptions(
                      //https://tile.osm.ch/switzerland/14/8544/5827.png
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                      attributionBuilder: (_) {
                        return Text(
                          "© OpenStreetMap contributors",
                          style: TextStyle(color:Colors.blue[800], fontSize: 20)
                        
                        );
                      },
                    ),
                    MarkerLayerOptions(
                      markers: _markersList,
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children:[
                    Center(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(), 
                        child: Text('Close')
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: _distFromBottom
                    )
                  ] 
                ),
              ]
          );
  }
}