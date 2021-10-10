import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

class AuthedHomeScreen extends StatelessWidget {
  static final routeName = '/homeauthed';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('You are Authenticated!'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text('You are Autneticated!',
              style: TextStyle(fontSize: 25),
            ),
          ),
          SizedBox(height: 10,),
          ElevatedButton(
            onPressed: () { Provider.of<Auth>(context, listen: false).signout(); }, 
            child: Text('Log Out', style: TextStyle(fontSize: 20),))
        ]
      ),
      
    );
  }
}