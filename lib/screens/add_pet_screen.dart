import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../validators/validators.dart';
import '../widgets/card_header.dart';
import '../widgets/image_select.dart';
import '../providers/pet.dart';

class AddPetScreen extends StatelessWidget {
  static String routeName = '/addpet';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final _form = Provider.of<Pet>(context, listen: false);
    
    Future<void> _saveForm() async {
      final isValid = _formKey.currentState!.validate();
      if (!isValid) {
        print('Form is invalid');
        return;
      } else {
        print('Form is valid');
        _formKey.currentState!.save();
        try {
          _form.addPet(
            _form.getFormValue('name'), 
            _form.getFormValue('animal'), 
            _form.getFormValue('description'), 
            _form.getFormValue('lastSeen'), 
            _form.getFormValue('picture'), 
            '52.397532',
            '-1.997979'
            // _form.getFormValue('lat'), 
            // _form.getFormValue('lng')
          );
        } catch(err) {
          print(err);
        }
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
                                  validator: (value) => Validators.validText(value),
                                  onSaved: (value) { _form.addToForm('name', value); },
                                  onTap: () {},
                                ),
                                TextFormField(
                                  decoration: InputDecoration(labelText: 'Animal'),
                                  keyboardType: TextInputType.text,
                                  validator: (value) => Validators.validText(value),
                                  onSaved: (value) { _form.addToForm('animal', value); },
                                  onTap: () {},
                                ),
                                TextFormField(
                                  decoration: InputDecoration(labelText: 'Description'),
                                  keyboardType: TextInputType.text,
                                  validator: (value) => Validators.validText(value),
                                  onSaved: (value) { _form.addToForm('description', value); },
                                  onTap: () {},
                                ),
                                TextFormField(
                                  decoration: InputDecoration(labelText: 'Last Seen'),
                                  keyboardType: TextInputType.visiblePassword,
                                  validator: (value) => Validators.validText(value),
                                  onSaved: (value) { _form.addToForm('lastSeen', value); },
                                  onTap: () {},
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                ImageSelect(false,_form.addToForm),
                                ElevatedButton(
                                  onPressed: _saveForm, 
                                  child: Text('Add Pet'))
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