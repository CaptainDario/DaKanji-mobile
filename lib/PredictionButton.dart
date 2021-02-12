import 'package:da_kanji_recognizer_mobile/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class PredictionButton extends StatelessWidget {
  String char;

  PredictionButton(String char) {
    this.char = char;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(0),
          child: MaterialButton(
            color: Colors.white.withAlpha(50),
            padding: EdgeInsets.all(0),
            // copy the character to clipboar on single press
            onPressed: () {
              Clipboard.setData(new ClipboardData(text: this.char));
            },
            // open the prediction in a dictionary (set in settings)
            onLongPress: () {
              Clipboard.setData(new ClipboardData(text: this.char));
              launch(SETTINGS.openWithSelectedDictionary(this.char));
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
      )
    );
  }
}
