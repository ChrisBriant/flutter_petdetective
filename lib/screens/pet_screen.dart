import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pet.dart';
import '../providers/auth.dart';
import '../providers/case_provider.dart';
import '../dialogs/request_dialog.dart';
import '../screens/cases_requests_screen.dart';
import '../screens/pet_person_map_screen.dart';

class PetScreen extends StatelessWidget {
  static final routeName = '/petscreen';

  @override
  Widget build(BuildContext context) {
    final _petProvider = Provider.of<Pet>(context, listen: false);
    final _caseProvider = Provider.of<CaseProvider>(context, listen: true);
    final _auth = Provider.of<Auth>(context, listen: false);
    final Map<String,dynamic>? args = ModalRoute.of(context)!.settings.arguments as Map<String,dynamic>?;

    //final MissingPet _pet = _petProvider.getPet(args!['petId']);
    final MissingPet _pet = _petProvider.getSelectedPet!;
    final bool _isDetective = args!['isDetective'];
    

    // if(args != null) {
    //   _sendLocationTo = args['sendLocationDataTo'];
    // } else {
    //   _sendLocationTo = 'form';
    // }

    _requestCase() {
      showDialog(
        context: context, 
        builder: (ctx) => RequestDialog(_pet.id)
      );
    }

    print('User Id');
    print(_auth.id);
    print(_pet.isCaseOpen);
    print(_pet.requestsIds);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(_pet.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            elevation: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Center(
                    child:Text(
                      'Have you seen this ${_pet.animal}?', 
                      style: Theme.of(context).textTheme.bodyText1!.merge(TextStyle(fontWeight: FontWeight.bold, fontSize: 26))
                    )
                  ),
                ),  
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: Image.network(_pet.imgUrl),
                  ),
                ),
                TextPair(text1: 'Name:  ', text2: _pet.name ),
                TextPair(text1: 'Animal:  ', text2: _pet.animal ),
                TextPair(text1: 'Description:  ', text2: _pet.description ),
                TextPair(text1: 'Last Seen:  ', text2: _pet.lastSeen ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical:10,horizontal:20),
                  child: ElevatedButton(
                    onPressed: () {Navigator.of(context).pushNamed(PetPersonMapScreen.routeName,arguments: {'mode':'single-pet', 'petId' : _pet.id});}, 
                    child: Text('View on Map')),
                ),
                _isDetective 
                ? FutureBuilder<int>(
                  future: _auth.id,  
                  builder: (ctx,userId) => userId.connectionState == ConnectionState.waiting
                  ? CircularProgressIndicator()
                  : Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical:10,horizontal:20),
                          child: ElevatedButton(
                            onPressed: _pet.isCaseOpen || _pet.requestsIds.contains(userId.data) || _caseProvider.getPetRequests.contains(_pet.id)
                            ? null 
                            : _requestCase, 
                            child: Text('Request Case')),
                        ),
                      ]
                    ),
                )
                //OWNER BUTTONS
                : Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical:10,horizontal:20),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pushNamed(
                          CaseRequestScreen.routeName,
                          arguments: {
                          'petId':_pet.id,
                          }
                        ), 
                        child: Text('View Cases / Requests')
                      ),
                    )
                  ],
                )
              ],),
            )
          ],
        )

    );
  }
}

class TextPair extends StatelessWidget {
  final String text1;
  final String text2;

  const TextPair({
    required this.text1,
    required this.text2
  });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Text(text1,style: Theme.of(context).textTheme.bodyText1!.merge(TextStyle(fontWeight: FontWeight.bold))),
          Text(' '+text2, style: Theme.of(context).textTheme.bodyText1)
        ],
      ),
    );
  }
}