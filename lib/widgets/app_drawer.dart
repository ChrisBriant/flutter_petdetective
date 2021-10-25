import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../screens/cases_requests_screen.dart';
import '../screens/user_profile_screen.dart';

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
            onTap: () { 
              Navigator.of(context).pop();
              _auth.signout(); 
            },
          )

        ],),
      
    );
  }
}