import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

import 'package:url_launcher/url_launcher.dart';
import 'package:intent/intent.dart' as android_intent;
import 'package:intent/extra.dart' as android_extra;
import 'package:intent/action.dart' as android_action;

import 'package:da_kanji_recognizer_mobile/globals.dart';

class PredictionButton extends StatelessWidget {
  String char;

  PredictionButton(String char) {
    this.char = char;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 1,
        child: Container(
          child: MaterialButton(
            color: Colors.white.withAlpha(50),
            padding: EdgeInsets.all(0),
            // copy the character to clipboard on single press
            onPressed: () {
              if (this.char != " ")
                Clipboard.setData(new ClipboardData(text: this.char));
            },
            // open prediction in the dictionary set in setting on long press
            onLongPress: () async {
              if (this.char != " ") {
                // the prediction should be translated with system dialogue
                if(SETTINGS.openWithDefaultTranslator){ 
                  if(Platform.isAndroid){
                    android_intent.Intent()
                      ..setAction(android_action.Action.ACTION_TRANSLATE)
                      ..putExtra(android_extra.Extra.EXTRA_TEXT, this.char)
                      ..startActivity().catchError((e) => print(e));
                  }
                  else if(Platform.isIOS && false){
                    print("iOS is not implemented for choosing translator");
                  }
                }
                else{
                  launch(SETTINGS.openWithSelectedDictionary(this.char));
                }
              }
            },
            child: FittedBox(
              child: Text(
                this.char,
                textAlign: TextAlign.center,
                style: new TextStyle(fontSize: 1000.0),
              )
            )
          )
        )
      
    );
  }
}
