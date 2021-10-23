import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/case_provider.dart';
import '../providers/pet.dart';


class CaseRequestScreen extends StatelessWidget {
  static final routeName = '/caserequest';
  
  

  @override
  Widget build(BuildContext context) {
    final Map<String,dynamic>? args = ModalRoute.of(context)!.settings.arguments as Map<String,dynamic>?;
    final int _petId = args!['petId'];
    final _caseProvider = Provider.of<CaseProvider>(context, listen: true);
    final _petProvider = Provider.of<Pet>(context, listen: false);

    final MissingPet _pet = _petProvider.getSelectedPet!;
    print(_pet.id);



    return Scaffold(
      appBar: AppBar(title: Text('Cases and Requests'),),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              FutureBuilder<List<DetectiveRequest>>(
                future: _caseProvider.getRequestsByPetId(_pet.id),
                builder: (ctx, reqs) => reqs.connectionState == ConnectionState.waiting
                ? Container(
                  height: 100,
                  width: 100,
                  child:CircularProgressIndicator()
                )
                : Column(
                  children: [ 
                   Card(
                      elevation: 12,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Container(
                          width: double.infinity,
                          child: Column(
                              children: [
                                Text('Detective Requests',
                                  style: Theme.of(context).textTheme.bodyText1!.merge(TextStyle(fontWeight: FontWeight.bold, fontSize: 26))
                                ),
                                reqs.data!.length > 0
                                ? ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: reqs.data!.length,
                                    itemBuilder: (ctx,i) => RequestItem(reqItem: reqs.data![i],acceptHandler: _caseProvider.acceptRequest,)
                                  )
                                : Text(
                                    'This pet has no requests.',
                                    style: Theme.of(context).textTheme.bodyText1!.merge(TextStyle(fontWeight: FontWeight.bold, fontSize: 22))
                                ),
                              ]
                            ),
                        ),
                      )
        
                    )
             
                  ]
                ),
              ),
              SizedBox(height: 20,),
              FutureBuilder<List<Case>>(
                future: _caseProvider.getCases(_pet.id),
                builder: (ctx, cases) => cases.connectionState == ConnectionState.waiting
                ? CircleAvatar()
                : Card(
                    elevation: 12,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        width: double.infinity,
                        child: Column(
                          children: [
                            Text('Cases',
                              style: Theme.of(context).textTheme.bodyText1!.merge(TextStyle(fontWeight: FontWeight.bold, fontSize: 26))
                            ), 
                            cases.data!.length > 0
                            ? ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: cases.data!.length,
                              itemBuilder: (ctx, i) => CaseItem(
                                key: ValueKey(cases.data![i].id), 
                                detective: cases.data![i].detective.name, 
                                status: 'Open'
                              )
                            )
                            : Text(
                              'This pet has no cases.',
                              style: Theme.of(context).textTheme.bodyText1!.merge(TextStyle(fontWeight: FontWeight.bold, fontSize: 26))
                            ),
                          ]
                        ),
                      ),
                    ),
                  )
        
              ),
              SizedBox(height:50),
              ElevatedButton(
               onPressed: () => Navigator.of(context).pop(), 
               child: Text('Back')
              )  
            ],
            
          ),
        ),
      )
    );
  }
}

class RequestItem extends StatefulWidget {
  final DetectiveRequest reqItem;
  final Function acceptHandler;

  const RequestItem({
    required this.reqItem,
    required this.acceptHandler,
    Key? key,
  }) : super(key: key);

  @override
  _RequestItemState createState() => _RequestItemState();
}

class _RequestItemState extends State<RequestItem> {
  bool _enableAccept = true;

  @override
  Widget build(BuildContext context) {
    
    _acceptRequest(id) async {
      setState(() {
        _enableAccept = false;
      });

      try {
        await widget.acceptHandler(id);
      } catch(err) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.toString()),
        ));
      }
      
      setState(() {
        _enableAccept = true;
      });
    }
    
    return Container(
      key: ValueKey(widget.reqItem.id),
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
                text2: widget.reqItem.detective.name
              ),    
              //Text(reqs.data![i].detective.name),
              TextPairColumn(
                text1: 'Description:', 
                text2: widget.reqItem.description
              ),
              Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: _enableAccept
                    ? () { _acceptRequest(widget.reqItem.id); }
                    : null,
                    child: Text('Accept')
                  ),
                ),
              )
            ]
          ),
        )
      );
  }
}

class CaseItem extends StatelessWidget {
  final String detective;
  final String status;
  const CaseItem({ 
    required this.detective,
    required this.status,
    Key? key 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
            text2: detective
          ),    
          //Text(reqs.data![i].detective.name),
          TextPairColumn(
            text1: 'Status:', 
            text2: status
          ),
          Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 100,
              child: ElevatedButton(
                onPressed: () { },
                child: Text('View Case')
              ),
            ),
          )
        ]
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