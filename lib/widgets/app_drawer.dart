import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

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
            leading: Icon(Icons.folder_shared),
            title: Text('My Cases / Requests'),
            onTap: () {  },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () { _auth.signout(); },
          )

        ],),
      
    );
  }
}