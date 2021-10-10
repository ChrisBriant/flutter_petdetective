import 'package:flutter/material.dart';

import '../screens/signin_screen.dart';
import '../screens/register_screen.dart';

class HomeScreen extends StatelessWidget {
  static final routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
      ),
      body: LayoutBuilder(
        builder: (ctx, constraints) => SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Pet Detective',
                style: TextStyle(fontFamily: 'Acme', fontSize: 60)
              ),
              Container(
                height: constraints.maxHeight * 0.6,
                child: Image.asset(
                  'assets/images/wammel3.png',
                fit: BoxFit.cover,
              )),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed(SigninScreen.routeName), 
                child: Text('Sign In'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed(RegisterScreen.routeName),  
                child: Text('Register')
              ),
            ],),
        ),
      ),       
    );
  }
}