import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/signin_screen.dart';
import './providers/auth.dart';
import '../screens/home_screen.dart';
import '../screens/wait_screen.dart';
import '../screens/register_screen.dart';
import '../screens/authed_home_screen.dart';
import '../screens/signup_completed_screen.dart';

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
      child: Consumer<Auth>(
        builder: (ctx, auth,_) => MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                primary: Colors.amber.shade900,
                minimumSize: Size(double.infinity,40),
                textStyle: TextStyle(fontSize: 20),
              )
            ),
            // textTheme: TextTheme(
            // ),
            primarySwatch: Colors.pink
          ),
          //home: HomeScreen(),
          home: FutureBuilder(
              future: auth.isAuthenticated(),
              builder: (ctx,authed) =>  authed.connectionState == ConnectionState.waiting
              ? WaitScreen()
              : authed.data == true ? AuthedHomeScreen() : HomeScreen()
            ),
          routes: {
            SigninScreen.routeName : (ctx) => SigninScreen(),
            RegisterScreen.routeName : (ctx) => RegisterScreen(),
            SignupCompleteScreen.routeName : (ctx) => SignupCompleteScreen(),
            AuthedHomeScreen.routeName : (ctx) => AuthedHomeScreen(),
          },
        ),
      ),
    );
  }
}
