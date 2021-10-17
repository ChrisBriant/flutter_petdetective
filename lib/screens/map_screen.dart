import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import "package:latlong2/latlong.dart" as latLng;
import 'package:provider/provider.dart';

import '../providers/location_provider.dart';

class MapScreen extends StatelessWidget {
  static String routeName = '/mapscreen';
  


  @override
  Widget build(BuildContext context) {
    final _locationProvider = Provider.of<LocationProvider>(context, listen: true);
    final Map<String,String>? args = ModalRoute.of(context)!.settings.arguments as Map<String,String>?;
    String? _sendLocationTo = '';
    String? _buttonText = '';
    if(args != null) {
      _sendLocationTo = args['sendLocationDataTo'];
    } else {
      _sendLocationTo = 'form';
    }
    double _distFromBottom = MediaQuery.of(context).size.height * 0.10;

    //PROBABLY NOT NEEDED
    //switch (_sendLocationTo) {
    //   case 'form':
    //     _buttonText = 'Set Location';
    //     break;
    //   case 'form':
    //     _buttonText = 'Set Location';
    //     break;
    //   default:
    //     //_buttonText = 'Set Location';
    //     break;
    // }


    return FutureBuilder(
            future: _locationProvider.getLocationData() ,
            builder: (ctx,snapshot) => snapshot.connectionState == ConnectionState.waiting 
            ? CircularProgressIndicator()
            : Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    center: latLng.LatLng(_locationProvider.lat!, _locationProvider.lng!),
                    zoom: 13.0,
                    onTap: (pos,latLng) { 
                      //_locationProvider.setLocationData(latLng.latitude, latLng.longitude);
                      switch (_sendLocationTo) {
                        case 'form':
                          _locationProvider.setLocationData(latLng.latitude, latLng.longitude);
                          break;
                        case 'prefs':
                          _locationProvider.setLocationData(latLng.latitude, latLng.longitude);
                          _locationProvider.setMyLocation(latLng.latitude, latLng.longitude);
                          break;
                        default:
                          _locationProvider.setLocationData(latLng.latitude, latLng.longitude);
                      }
                      
                    }
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
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: latLng.LatLng(_locationProvider.lat!, _locationProvider.lng!),
                          builder: (ctx) =>
                          Container(
                            child: Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 36.0,
                            ),
                          ),
                        ),
                      ],
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
                        child: Text('Set Location')
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: _distFromBottom
                    )
                  ] 
                ),
              ]
            ),
          );
  }
}