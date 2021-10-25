import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../widgets/text_pair.dart';
import '../widgets/app_drawer.dart';
import './map_screen.dart';
import './pet_person_map_screen.dart';

class UserProfileScreen extends StatelessWidget {
  static const routeName = '/userprofile'; 

  @override
  Widget build(BuildContext context) {
    final _auth = Provider.of<Auth>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('My Profile'),),
      drawer: AppDrawer(),
      body: FutureBuilder<UserProfile?>(
        future: _auth.myProfile,
        builder: (ctx,auth) => auth.connectionState == ConnectionState.waiting 
        ? CircularProgressIndicator()
        : auth.data == null
        ? Text('')
        : Column(
          children: [
            Card(
              elevation: 12,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    TextPair(
                      text1: 'Name: ', 
                      text2: auth.data!.name
                    ),
                    TextPair(
                      text1: 'Registraion: ',
                      text2: 
                      auth.data!.isDetective
                      ? 'detective.'
                      : 'owner',
                    ),
                    Divider(thickness: 5,),
                    Text(
                      'My Location',
                      style: Theme.of(context).textTheme.bodyText1!.merge(TextStyle(fontWeight: FontWeight.bold))
                    ),
                    auth.data!.lat == null || auth.data!.lng == null
                    ? Column(
                      children: [
                        Text('You have no location set.'),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(MapScreen.routeName,arguments: {'sendLocationDataTo': 'prefs'});
                          }, 
                          child: Text('Set Location')
                        )
                      ],
                    )
                  : Column(
                    children: [
                      Text('My location'),
                      ElevatedButton(
                        onPressed: () {}, 
                        child: Text('View on Map')
                      ),
                      ElevatedButton(
                        onPressed: () {}, 
                        child: Text('Change Location')
                      ),
                    ],
                  ),
                  Divider(thickness: 5,),
                  TextPair(
                    text1: 'Requests:',
                    text2: auth.data!.requestCount.toString(),
                  ),
                  TextPair(
                    text1: 'Cases:',
                    text2: auth.data!.caseCount.toString(),
                  ),      
                  ],
                ),
              )
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              child: ElevatedButton(
                onPressed: () { Navigator.of(context).pop();}, 
                child: Text('Close')),
            )
          ],
        ),
      ),
    );
  }
}