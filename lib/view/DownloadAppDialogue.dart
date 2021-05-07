import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';



/// Show a dialogue using [context] with a [title], some [text] and a button
/// to open the [url].
  void showDownloadDialogue(
    BuildContext context, String title, String text, String url){

    showDialog(
      context: context,
      builder: (BuildContext context){ 
        return SimpleDialog(
          title: Center(child: Text(title)),
          children: [
            Center(child:
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      launch(url);
                    },
                    child: Text(text)
                  ),
                  SizedBox(width: 10,),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    child: Text("Close")
                  ),
                ]
              )
            ))
          ],
        );
      }
    );
  }