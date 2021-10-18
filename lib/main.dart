import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/signin_screen.dart';
import './providers/auth.dart';
import './providers/pet.dart';
import './providers/location_provider.dart';
import '../screens/home_screen.dart';
import '../screens/wait_screen.dart';
import '../screens/register_screen.dart';
import 'screens/detective_stack/detective_home_screen.dart';
import '../screens/signup_completed_screen.dart';
import 'screens/owner_stack/add_pet_screen.dart';
import '../screens/map_screen.dart';
import '../screens/pet_screen.dart';
import '../screens/detective_stack/detective_home_screen.dart';
import '../screens/owner_stack/owner_home_screen.dart';

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
        ),
        ChangeNotifierProvider(
          create: (ctx) => Pet({
            'name' : '',
            'description' : '',
            'lastSeen' : '',
            'animal' : '',
            'picture' : '',
            'lat' : '0.0',
            'lng' : '0.0'
          })
        ),
        ChangeNotifierProvider(
          create: (ctx) => LocationProvider()
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
            textTheme: TextTheme(
              bodyText1: TextStyle(fontSize: 22),
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
              : authed.data == true 
                ? FutureBuilder(
                  future: auth.isDetective(),
                  builder: (ctx,isDetective) =>  isDetective.connectionState == ConnectionState.waiting
                  ? WaitScreen()
                  : isDetective.data == true ? DetectiveHomeScreen() : OwnerHomeScreen() 
                ) 
                : HomeScreen()
            ),
          routes: {
            SigninScreen.routeName : (ctx) => SigninScreen(),
            RegisterScreen.routeName : (ctx) => RegisterScreen(),
            SignupCompleteScreen.routeName : (ctx) => SignupCompleteScreen(),
            OwnerHomeScreen.routeName : (ctx) => OwnerHomeScreen(),
            DetectiveHomeScreen.routeName : (ctx) => DetectiveHomeScreen(),
            AddPetScreen.routeName : (ctx) => AddPetScreen(),
            PetScreen.routeName : (ctx) => PetScreen(),
            MapScreen.routeName: (ctx) => MapScreen(),
          },
        ),
      ),
    );
  }
}
