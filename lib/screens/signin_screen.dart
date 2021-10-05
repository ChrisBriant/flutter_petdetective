import 'package:flutter/material.dart';

import '../validators/validators.dart';

class SigninScreen extends StatelessWidget {
  static final routeName = '/home';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  
  @override
  Widget build(BuildContext context) {
    
    Future<void> _saveForm() async {
      final isValid = _formKey.currentState!.validate();
      if (!isValid) {
        print('Form is invalid');
        return;
      } else {
        _formKey.currentState!.save();
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Sign In'),),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 12,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'E-mail'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => Validators.validEmail(value),
                    onSaved: (value) { print(value); },
                    onTap: () {},
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Password'),
                    //obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    validator: (value) => Validators.validPassword(value),
                    onSaved: (value) { print(value); },
                    onTap: () {},
                  ),
                  ElevatedButton(
                    onPressed: _saveForm, 
                    child: Text('Sign In'))
                ],
              ),
            ),
          )
        ),
      )
    );
  }
}