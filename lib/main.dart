import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/signin_screen.dart';
import './providers/auth.dart';
import '../screens/home_screen.dart';

void main() {
  runApp(PetDetective());
}

class PetDetective extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth({
            'username' : '',
            'password' : '',
            'email' : '',
            'passchk' : ''
          })
        )

      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity,40),
              textStyle: TextStyle(fontSize: 20),
            )
          ),
          // textTheme: TextTheme(
          // ),
          primarySwatch: Colors.pink,
        ),
        home: HomeScreen(),
        routes: {
          SigninScreen.routeName : (ctx) => SigninScreen(),
        },
      ),
    );
  }
}
