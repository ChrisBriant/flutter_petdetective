import 'package:flutter/material.dart';
import 'package:petdetective/screens/owner_stack/add_pet_screen.dart';
import 'package:provider/provider.dart';

import '../../providers/auth.dart';
//import '../wait_screen.dart';
import '../owner_stack/add_pet_screen.dart';

class OwnerHomeScreen extends StatelessWidget {
  static final routeName = '/homedetective';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome Owner'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('You are an owner'),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed(AddPetScreen.routeName), 
            child: Text('Add Pet')
          ),
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