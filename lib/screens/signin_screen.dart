import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'detective_stack/detective_home_screen.dart';
import '../validators/validators.dart';
import '../widgets/card_header.dart';
import '../providers/auth.dart';

class SigninScreen extends StatelessWidget {
  static final routeName = '/signin';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  
  @override
  Widget build(BuildContext context) {
    final _form = Provider.of<Auth>(context, listen: false);

    Future<void> _saveForm() async {
      final isValid = _formKey.currentState!.validate();
      if (!isValid) {
        print('Form is invalid');
        return;
      } else {
        _formKey.currentState!.save();
        print(_form.getFormValue('email'));
        print(_form.getFormValue('password'));
        try {
          await _form.signin (
            _form.getFormValue('email')!,
            _form.getFormValue('password')!,
          );
        } catch(err) {
          print(err);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(err.toString()),
          ));
          return;
        }
        Navigator.of(context).pop();
        //Navigator.of(context).pushReplacementNamed(AuthedHomeScreen.routeName);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Sign In'),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
        [
          Padding(
            padding: EdgeInsets.all(12),
            child: Form(
              key: _formKey,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Stack(
                  children: [
                    Card(
                      elevation: 12,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                height: 20,
                            ),
                            TextFormField(
                              decoration: InputDecoration(labelText: 'E-mail'),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) => Validators.validEmail(value),
                              onSaved: (value) { _form.addToForm('email', value); },
                              onTap: () {},
                            ),
                            TextFormField(
                              decoration: InputDecoration(labelText: 'Password'),
                              obscureText: true,
                              keyboardType: TextInputType.visiblePassword,
                              validator: (value) => Validators.validText(value),
                              onSaved: (value) { _form.addToForm('password', value); },
                              onTap: () {},
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            ElevatedButton(
                              onPressed: _saveForm, 
                              child: Text('Sign In'))
                          ],
                        ),
                      ),
                    ),
                    CardHeader(title:'Sign In'),
                  ]
                ),
              )
            ),
          ),
        ]
      )
    );
  }
}

