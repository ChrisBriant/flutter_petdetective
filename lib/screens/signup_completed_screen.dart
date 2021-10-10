import 'package:flutter/material.dart';

import '../screens/signin_screen.dart';

class SignupCompleteScreen extends StatelessWidget {
  static const routeName = '/signupcomplete'; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Singup Complete'),
      ),
      body: Column(
        children: [
          Center(
            child:Text(
              'Sigup Complete!',
              style: TextStyle(fontSize: 20)
            )
          ),
          SizedBox(height: 10,),
          Padding(
            padding: EdgeInsets.all(10),
            child: Center(
              child:Text('Congratulations! You have successfully signed up for an account. ' + 
                        'Please check your email and click the link to confirm. Once you are done, ' + 
                        'return to the sign in page to login.',
                        style: TextStyle(fontSize: 16),
                    ),
          
            ),
          ),
          SizedBox(height: 10,),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed(SigninScreen.routeName),
            child: Text('Sign In')
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      
      ),
      
    );
  }
}