import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../validators/validators.dart';
import '../widgets/card_header.dart';
import '../providers/auth.dart';
import '../screens/signup_completed_screen.dart';

class RegisterScreen extends StatefulWidget {
  static final routeName = '/register';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordCheckCtrl = new TextEditingController();
  final TextEditingController _passwordCtrl = new TextEditingController();
  bool _regType = true;
  String _regTypeText = 'Register as owner';
  String _regDescription = 'I have lost a pet and want to find someone to help find him/her.';

  @override
  void initState() {
    print('hello');
    super.initState();
    _passwordCheckCtrl.addListener(() {});
    _passwordCtrl.addListener(() { });

  }

  @override
  void dispose() {
    _passwordCheckCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _form = Provider.of<Auth>(context, listen: false);

    String? _validPasswordMatch(val) {
      String? _validation = Validators.validPassword(val); 
      if(_validation != null) {
        return _validation;
      }
      if(_passwordCtrl.text != _passwordCheckCtrl.text) {
        return 'Passwords do not match.';
      }

      return null;

    } 


    Future<void> _saveForm() async {
      final isValid = _formKey.currentState!.validate();
      if (!isValid) {
        print('Form is invalid');
        return;
      } else {
        _formKey.currentState!.save();

        bool _success = false;
        String _email = _form.getFormValue('email');
        String _password = _form.getFormValue('password');
        String _passChk = _form.getFormValue('passchk');
        String _username = _form.getFormValue('username');

        print(!_regType);

        _success = await _form.signup (
          _email,
          _password,
          _passChk,
          _username,
          !_regType
        );

        if(_success) {
          Navigator.of(context).pushReplacementNamed(SignupCompleteScreen.routeName);
        }
      }
    }
    
    return Scaffold(
      appBar: AppBar(title: Text('Register'),),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
          [
            SwitchListTile(
              title:Text(_regTypeText),
              value: _regType,
              subtitle: Text(_regDescription), 
              onChanged:  (val) {
                setState(() {
                  _regType = val;
                  if(!val) {
                    _regTypeText = 'Register as pet detective';
                    _regDescription = 'I am a pet detective and offer services finding lost pets.'; 
                  } else {
                    _regTypeText = 'Register as pet owner';
                    _regDescription = 'I have lost a pet and want to find someone to help find him/her.'; 
                  }
                  
                }); 
       
              }
            ),
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
                                  decoration: InputDecoration(labelText: 'User Name'),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) => Validators.validUserName(value),
                                  onSaved: (value) { _form.addToForm('username', value);  },
                                  onTap: () {},
                                ),
                                TextFormField(
                                  decoration: InputDecoration(labelText: 'E-mail'),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) => Validators.validEmail(value),
                                  onSaved: (value) { _form.addToForm('email', value);  },
                                  onTap: () {},
                                ),
                                TextFormField(
                                  decoration: InputDecoration(labelText: 'Password'),
                                  //obscureText: true,
                                  keyboardType: TextInputType.visiblePassword,
                                  validator: (value) => Validators.validPassword(value),
                                  onSaved: (value) { _form.addToForm('password', value);  },
                                  onTap: () {},
                                  controller: _passwordCtrl,
                                ),
                                TextFormField(
                                  decoration: InputDecoration(labelText: 'Confirm'),
                                  //obscureText: true,
                                  keyboardType: TextInputType.visiblePassword,
                                  validator: (value) => _validPasswordMatch(value),
                                  onSaved: (value) { _form.addToForm('passchk', value);  },
                                  onTap: () {},
                                  controller: _passwordCheckCtrl,
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
                      CardHeader(title:_regTypeText),
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

