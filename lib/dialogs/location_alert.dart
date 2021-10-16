import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/location_provider.dart';

class LocationAlert extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    final _locationProvider = Provider.of<LocationProvider>(context, listen: false);

    return AlertDialog(
      title: Text('No Location is Set'),
      content: FutureBuilder(
        future: _locationProvider.getLocationData(),
        builder: (ctx,data) => data.connectionState == ConnectionState.waiting
        ? Text('Loading Location')
        : Text('Your current location is detected as: \n ${_locationProvider.lat!.toStringAsFixed(4)},${_locationProvider.lng!.toStringAsFixed(4)}'),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            await _locationProvider.setMyLocation(_locationProvider.lat!, _locationProvider.lng!);
            Navigator.of(context).pop();
          }, 
          child: Text('Keep this Location')
        ),
        ElevatedButton(
          onPressed: () {}, 
          child: Text('Select on Map')
        )
      ],
      
    );
  }
}