import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/case_provider.dart';
import '../providers/pet.dart';
import '../providers/auth.dart';


class CaseRequestScreen extends StatelessWidget {
  static final routeName = '/caserequest';
  
  

  @override
  Widget build(BuildContext context) {
    final _caseProvider = Provider.of<CaseProvider>(context, listen: true);
    final _petProvider = Provider.of<Pet>(context, listen: false);



    return Scaffold(
      appBar: AppBar(title: Text('Cases and Requests'),),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              FutureBuilder<List<DetectiveRequest>>(
                future: _caseProvider.getRequests(byPet: false),
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
                future: _caseProvider.getCases(byPet: false),
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
                              itemBuilder: (ctx, i) => CaseItem(pCase:cases.data![i])
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
    final _auth = Provider.of<Auth>(context, listen: false);
    
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

    _viewRequest(id) {
      print('View Request');
    }
    
    return Container(
      key: ValueKey(widget.reqItem.id),
        child: FutureBuilder<bool>(
          future: _auth.isDetective(),
          builder: (ctx,auth) => auth.connectionState == ConnectionState.waiting
          ? CircleAvatar()
          : Container(
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
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.reqItem.pet.imgUrl),
                  )
                ), 
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: auth.data!
                  ? TextPairColumn(
                    text1: 'Pet Name:', 
                    text2: widget.reqItem.pet.name
                  )
                  : TextPairColumn(
                    text1: 'Detective:', 
                    text2: widget.reqItem.detective.name
                  ),
                ),    
                Spacer(),
                Container(
                  width: MediaQuery.of(context).size.width * 0.15,
                  child: TextButton(
                    onPressed: _enableAccept
                    ? () { _viewRequest(widget.reqItem.id); }
                    : null,
                    child: Text('View')
                  ),
                ),
                widget.reqItem.accepted
                ? Icon(
                  Icons.check,
                  color: Colors.green.shade600,
                )
                : auth.data!
                ? Icon(
                  Icons.dangerous,
                  color: Colors.red.shade600,
                )
                : Container(
                  width: MediaQuery.of(context).size.width * 0.15,
                  child: TextButton(
                    onPressed: _enableAccept
                    ? () { _acceptRequest(widget.reqItem.id); }
                    : null,
                    child: Text('Accept')
                  ),
                ),
              ]
            ),
          ),
        )
      );
  }
}

class CaseItem extends StatelessWidget {
  final Case pCase;

  const CaseItem({ 
    required this.pCase,
    Key? key 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _auth = Provider.of<Auth>(context, listen: false);

    _viewCase(id) {
      print('View Case $id');
    }

    return FutureBuilder<bool>(
      future: _auth.isDetective(),
      builder: (ctx,auth) => auth.connectionState == ConnectionState.waiting
      ? CircularProgressIndicator()
      : auth.data!
      ? Container(
        child: ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(pCase.pet.imgUrl),),
          title: Row(
            children: [
              Text('Name: ', style: TextStyle(fontWeight: FontWeight.bold),),
              Text(pCase.pet.name)
            ],
          ),
          subtitle: Text(pCase.pet.statusStr),
          onTap: () { _viewCase(pCase.id);} ,
        ),
      )
      : Container(
        child: ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(pCase.pet.imgUrl),),
          title: Row(
            children: [
              Text('Detective: ', style: TextStyle(fontWeight: FontWeight.bold),),
              Text(pCase.detective.name)
            ],
          ),
          subtitle: Text(pCase.pet.statusStr),
          onTap: () { _viewCase(pCase.id);} ,
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