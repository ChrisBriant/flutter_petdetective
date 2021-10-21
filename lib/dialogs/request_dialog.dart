import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../providers/case_provider.dart';

class RequestDialog extends StatefulWidget {
  final petId;

  const RequestDialog(this.petId);

  @override
  _RequestDialogState createState() => _RequestDialogState(petId);
}

class _RequestDialogState extends State<RequestDialog> {
  final TextEditingController _controller = TextEditingController();
  final petId;

  _RequestDialogState(this.petId);
  

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final _caseProvider = Provider.of<CaseProvider>(context, listen: false);

    _makeRequest() async {
      if(_controller.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Please enter some text"),
        ));
        return;
      }
      try {
        bool _success = await _caseProvider.makeRequest(petId, _controller.text);
        if(_success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Request Made"),
          ));
        }
      } catch(err) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
        ));
      }
      print(_controller.text);
    }

    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Make a Request',
                style: Theme.of(context).textTheme.bodyText1!.merge(TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
              ),
              SizedBox(height: 20),
              Text(
                'Enter a description below to the owner. They will review your request and then, once accpeted you will be assigned the case.'
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(labelText: 'Description',border: OutlineInputBorder()),
                maxLines: 3,
                keyboardType: TextInputType.text,
                controller: _controller,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _makeRequest, 
                child: Text('Request')
              ),
              ElevatedButton(
                onPressed: ()  {Navigator.of(context).pop();}, 
                child: Text('Cancel')
              )
            ]
          ),
        ),
      ),
    );
  }
}