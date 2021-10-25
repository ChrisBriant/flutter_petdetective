import 'package:flutter/material.dart';


class TextPair extends StatelessWidget {
  final String text1;
  final String text2;
  final bool multiLine;

  const TextPair({
    required this.text1,
    required this.text2,
    this.multiLine = false
  });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: !multiLine
        ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
              child: Text(text1,style: Theme.of(context).textTheme.bodyText1!.merge(TextStyle(fontWeight: FontWeight.bold)))
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              child: Text(text2, style: Theme.of(context).textTheme.bodyText1),           
            )
          ],
        )
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                child: Text(text1,style: Theme.of(context).textTheme.bodyText1!.merge(TextStyle(fontWeight: FontWeight.bold)))
              ),
              Container(
                width: double.infinity,
                child: Text(text2, style: Theme.of(context).textTheme.bodyText1)
              )
            ],
        )
    );
  }
}