import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/case_provider.dart';

class CaseRequestScreen extends StatelessWidget {
  static final routeName = '/caserequest';
  
  

  @override
  Widget build(BuildContext context) {
    final Map<String,dynamic>? args = ModalRoute.of(context)!.settings.arguments as Map<String,dynamic>?;
    final int _petId = args!['petId'];
    final _caseProvider = Provider.of<CaseProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('Cases and Requests'),),
      body: FutureBuilder<List<DetectiveRequest>>(
        future: _caseProvider.getRequestsByPetId(7),
        builder: (ctx, reqs) => reqs.connectionState == ConnectionState.waiting
        ? Container(
          height: 100,
          width: 100,
          child:CircularProgressIndicator()
        )
        : Column(
          children: [ 
            reqs.data!.length > 0
            ? Card(
              child: Column(
                children: [
                  Text('Detective Requests'), 
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: reqs.data!.length,
                    itemBuilder: (ctx,i) => Container(
                      key: ValueKey(reqs.data![i].id),
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(border: 
                            Border.all(
                              color: Colors.amber.shade200,
                              width: 1,
                              style: BorderStyle.solid
                            )
                          ),
                          child: Row(
                            children: [
                              TextPairColumn(
                                text1: 'Detective:', 
                                text2: reqs.data![i].detective.name
                              ),    
                              //Text(reqs.data![i].detective.name),
                              TextPairColumn(
                                text1: 'Description:', 
                                text2: reqs.data![i].description
                              ),
                              Spacer(),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  width: 100,
                                  child: ElevatedButton(
                                    onPressed: () {}, 
                                    child: Text('Accept')
                                  ),
                                ),
                              )
                            ]
                          ),
                        ),
                      )
                    ),
                  ]
              ),
            )
            : Text('This pet has no requests.'),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(), 
              child: Text('Back')
            )  

          ]
        ),
      )
    );
  }
}


class TextPairColumn extends StatelessWidget {
  final String text1;
  final String text2;

  const TextPairColumn({
    required this.text1,
    required this.text2
  });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text1,style: Theme.of(context).textTheme.bodyText1!
            .merge(TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          SizedBox(height: 10,),
          Text(text2, style: Theme.of(context).textTheme.bodyText1!
            .merge(TextStyle(fontSize: 16))
          )
        ],
      ),
    );
  }
}