import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth.dart';
import '../../providers/location_provider.dart';
import '../../providers/pet.dart';
import '../../dialogs/location_alert.dart';
import '../../screens/pet_screen.dart';

class DetectiveHomeScreen extends StatelessWidget {
  static final routeName = '/homedetective';


  @override
  Widget build(BuildContext context) {
    final _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final _petProvider = Provider.of<Pet>(context, listen: false);

    _checkLocation() async {
      bool _isLocationSet = await _locationProvider.isLocationSet;
      if(!_isLocationSet) {
        showDialog(
          context: context, 
          builder: (ctx) => LocationAlert()
        );
      }
    }

    _checkLocation();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome Detective'),
      ),
      body: FutureBuilder(
        future: _locationProvider.isLocationSet,
        builder: (ctx,locationSet) =>  locationSet.connectionState == ConnectionState.waiting
        ? CircularProgressIndicator()
        : SingleChildScrollView(
          child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pets Located Near You',
                      style: Theme.of(context).textTheme.bodyText1!.merge(TextStyle(fontWeight: FontWeight.bold, fontSize: 26))
                    ),
                    FutureBuilder<List<MissingPet>>(
                      future: _petProvider.getMissingPets(),
                      builder: (ctx, pets) => pets.connectionState == ConnectionState.waiting
                      ? Container(
                        height: 100,
                        width: 100,
                        child:CircularProgressIndicator()
                      )
                      : ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: pets.data!.length,
                          itemBuilder: (ctx,i) => ListTile(
                            key: ValueKey(pets.data![i].id),
                            leading: Container(
                              width: 100,
                              height: 100,
                              //child: Text('hello'),
                              child: Padding(
                                padding: EdgeInsets.all(5),
                                child: CircleAvatar(backgroundImage: NetworkImage(pets.data![i].imgUrl),)
                              )
                            ),
                            title: Text(
                              pets.data![i].name
                            ),
                            subtitle: Text(
                              pets.data![i].description
                            ),
                            onTap: () {Navigator.of(context).pushNamed(PetScreen.routeName, arguments: {'petId':pets.data![i].id });},
                          ) 
        
                          //Text(pets.data![i].id.toString()),
                        ),
                    ),
                    SizedBox(height: 10,),
                    ElevatedButton(
                      onPressed: () { Provider.of<Auth>(context, listen: false).signout(); }, 
                      child: Text('Log Out', style: TextStyle(fontSize: 20),))
                  ]
                ),
        ),
      )
    );
  }
}