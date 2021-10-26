import 'package:flutter/material.dart';
import 'package:petdetective/screens/detective_stack/detective_home_screen.dart';
import 'package:petdetective/screens/owner_stack/owner_home_screen.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../screens/cases_requests_screen.dart';
import '../screens/user_profile_screen.dart';
import '../screens/signin_screen.dart';
import '../screens/home_screen.dart';

class AppDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Auth _auth = Provider.of<Auth>(context, listen: false);

    return Drawer(
      child: Column(
        children: [
          SizedBox(height: 50,),
          Text(
            'Menu',
            style: TextStyle(fontSize: 22),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('My Profile'),
            onTap: () { 
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(UserProfileScreen.routeName); 
            },
          ),
          ListTile(
            leading: Icon(Icons.folder_shared),
            title: Text('My Cases / Requests'),
            onTap: () { 
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(CaseRequestScreen.routeName); 
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () async { 
              await _auth.signout(); 
              Navigator.of(context).pop();
              // if (await _auth.isDetective()) {
              //   //Navigator.popUntil(context,ModalRoute.withName(DetectiveHomeScreen.routeName));
              //   Navigator.of(context).pushAndRemoveUntil(
              //     MaterialPageRoute(
              //       builder: (ctx) => DetectiveHomeScreen()
              //     ), 
              //     (route) => false
              //   );
              //   //Navigator.of(context).pop();
              // } else {
              //   //Navigator.popUntil(context,ModalRoute.withName(OwnerHomeScreen.routeName));
              //   Navigator.of(context).pushAndRemoveUntil(
              //     MaterialPageRoute(
              //       builder: (ctx) => OwnerHomeScreen()
              //     ), 
              //     (route) => false
              //   );
              //   Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
              //   //Navigator.of(context).pop();
              // }
              // Navigator.of(context).pushAndRemoveUntil(
              //     MaterialPageRoute(
              //       builder: (ctx) => SigninScreen()
              //     ), 
              //     (route) => false
              // );

              // Navigator.of(context).pushNamedAndRemoveUntil(HomeScreen.routeName, (route) => false);
              

              
              //Navigator.of(context).pushNamed(HomeScreen.routeName);
              
            },
          )

        ],),
      
    );
  }
}