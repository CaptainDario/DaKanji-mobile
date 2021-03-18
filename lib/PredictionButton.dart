import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent/android_intent.dart';

import 'package:da_kanji_recognizer_mobile/globals.dart';

class PredictionButton extends StatefulWidget {
  final String char;

  PredictionButton({this.char});

  @override
  _PredictionButtonState createState() => _PredictionButtonState();

}


class _PredictionButtonState extends State<PredictionButton>{

  @override
  Widget build(BuildContext context){
  return AspectRatio(
    aspectRatio: 1,
    child: GestureDetector(
      child: MaterialButton(
        color: Colors.white.withAlpha(50),
        padding: EdgeInsets.all(0),
        // copy the character to clipboard on single press
        onPressed: () {
          if (widget.char != " "){
            Clipboard.setData(new ClipboardData(text: widget.char));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 1),
                content: Text("copied " + widget.char + " to clipboard"),
              )
            );
          }
        },
        
        // open prediction in the dictionary set in setting on long press
        onLongPress: () async {
          // only open a page when there is a prediction
          if (widget.char != " ") {
            // the prediction should be translated with system dialogue
            if(SETTINGS.openWithDefaultTranslator){ 
              if(Platform.isAndroid){
                AndroidIntent intent = AndroidIntent(
                  action: 'android.intent.action.TRANSLATE',
                  arguments: <String, dynamic>{
                    "android.intent.extra.TEXT" : widget.char
                  }
                );
                if(await intent.canResolveActivity())
                  await intent.launch();
                else{
                  showDialog(
                    context: context,
                    builder: (BuildContext context){ 
                      return SimpleDialog(
                        title: Center(child: Text("No translator installed")),
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                MaterialButton(
                                  color: Colors.white.withAlpha(50),
                                  onPressed: () {
                                    launch(PLAYSTORE_BASE_URL + GOOGLE_TRANSLATE_ID);
                                  },
                                  child: Text("Download Google Translate")
                                ) 
                              ]
                            )
                          )
                        ],
                      );
                    }
                  );
                }
              }
              else if(Platform.isIOS && false){
                print("iOS is not implemented for choosing translator");
              }
            }
            // offline dictionary takoboto (android)
            else if(SETTINGS.openWithTakoboto){
              if(Platform.isAndroid){
                AndroidIntent intent = AndroidIntent(
                    package: 'jp.takoboto',
                    action: 'jp.takoboto.SEARCH',
                    arguments: <String, dynamic>{
                      "android.intent.extra.PROCESS_TEXT": widget.char,
                    }
                );
                if(await intent.canResolveActivity())
                  await intent.launch();
                else{
                  showDialog(
                    context: context,
                    builder: (BuildContext context){ 
                      return SimpleDialog(
                        title: Center(child: Text("Takoboto not installed")),
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                MaterialButton(
                                  color: Colors.white.withAlpha(50),
                                  onPressed: () async {
                                    launch(PLAYSTORE_BASE_URL + TAKOBOTO_ID);
                                  },
                                  child: Text("Download takoboto")
                                ) 
                              ]
                            )
                          )
                        ],
                      );
                    }
                  );
                }
              }
            }
            else{
              launch(SETTINGS.openWithSelectedDictionary(widget.char));
            }
          }
        },
        child: FittedBox(
          child: Text(
            widget.char,
            textAlign: TextAlign.center,
            style: new TextStyle(fontSize: 1000.0),
          )
        )
      )
    )
  );
  }
}
