import 'package:flutter/material.dart';
import 'package:petdetective/screens/owner_stack/add_pet_screen.dart';
import 'package:provider/provider.dart';

import '../../providers/auth.dart';
import '../../providers/pet.dart';
import '../../screens/pet_screen.dart';
import '../owner_stack/add_pet_screen.dart';
import '../../widgets/app_drawer.dart';

class OwnerHomeScreen extends StatelessWidget {
  static final routeName = '/homedetective';


  @override
  Widget build(BuildContext context) {
    final _petProvider = Provider.of<Pet>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome Owner'),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You\'re Pets',
              style: Theme.of(context).textTheme.bodyText1!.merge(TextStyle(fontWeight: FontWeight.bold, fontSize: 26))
            ),
            FutureBuilder<List<MissingPet>>(
              future: _petProvider.getMyPets(),
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
                    onTap: () {
                        _petProvider.setSelectedPet = pets.data![i];
                        Navigator.of(context).pushNamed(
                          PetScreen.routeName, arguments: {
                            'petId':pets.data![i].id,
                            'isDetective' : false 
                          });
                    },
                  ) 
      
                  //Text(pets.data![i].id.toString()),
                ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed(AddPetScreen.routeName), 
              child: Text('Add Pet')
            ),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () { Provider.of<Auth>(context, listen: false).signout(); }, 
              child: Text('Log Out', style: TextStyle(fontSize: 20),))
          ]
        ),
      ),
      
    );
  }
}