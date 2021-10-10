import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../validators/validators.dart';
import '../widgets/card_header.dart';

class AddPetScreen extends StatelessWidget {
  static String routeName = '/addpet';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    
    Future<void> _saveForm() async {
      final isValid = _formKey.currentState!.validate();
      if (!isValid) {
        print('Form is invalid');
        return;
      } else {
        print('Form is valid');
        return;
      }
    }


    return Scaffold(
      appBar: AppBar(title: Text('Add Pet'),),
      body:SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
          [
            Padding(
              padding: EdgeInsets.all(12),
              child: Form(
                key: _formKey,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Stack(
                    children: [
                      Card(
                        elevation: 12,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  decoration: InputDecoration(labelText: 'Name'),
                                  keyboardType: TextInputType.text,
                                  validator: (value) => Validators.validUserName(value),
                                  onSaved: (value) {   },
                                  onTap: () {},
                                ),
                                TextFormField(
                                  decoration: InputDecoration(labelText: 'Animal'),
                                  keyboardType: TextInputType.text,
                                  validator: (value) => Validators.validEmail(value),
                                  onSaved: (value) {   },
                                  onTap: () {},
                                ),
                                TextFormField(
                                  decoration: InputDecoration(labelText: 'Description'),
                                  keyboardType: TextInputType.text,
                                  validator: (value) => Validators.validText(value),
                                  onSaved: (value) { },
                                  onTap: () {},
                                ),
                                TextFormField(
                                  decoration: InputDecoration(labelText: 'Last Seen'),
                                  keyboardType: TextInputType.visiblePassword,
                                  validator: (value) => Validators.validText(value),
                                  onSaved: (value) {   },
                                  onTap: () {},
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton(
                                  onPressed: _saveForm, 
                                  child: Text('Register'))
                              ],
                            ),
                          ),
                        ),
                      ),
                      CardHeader(title:'Add Pet'),
                    ]
                  ),
                )
              ),
            ),
          ]
        ),
      )
    );
  }
}