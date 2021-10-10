import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../screens/wait_screen.dart';

class AuthedHomeScreen extends StatelessWidget {
  static final routeName = '/homeauthed';


  @override
  Widget build(BuildContext context) {
    // if(Provider.of<Auth>(context, listen: false).isDetective() as bool) {
    //   print('This person is a detective.');
    // }

    return Scaffold(
      appBar: AppBar(
        title: Text('You are Authenticated!'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // FutureBuilder(
          //   builder: (ctx,isDetective) =>  isDetective.connectionState == ConnectionState.waiting
          //     ? WaitScreen()
          //     : isDetective.data == true
          //       ? Text('You are a detective')
          //       : Text('You are an owner') 
          // ),
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