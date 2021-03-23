import 'package:flutter/material.dart';

import 'HandlePredictions.dart';


class PredictionButton extends StatefulWidget {
  final String char;

  PredictionButton({this.char});

  @override
  _PredictionButtonState createState() => _PredictionButtonState();

}


class _PredictionButtonState extends State<PredictionButton>{

  @override
  Widget build(BuildContext context){
  return Transform.scale(
    scale: 0.9, 
    child: AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        child: MaterialButton(
          color: Colors.white.withAlpha(50),
          padding: EdgeInsets.all(0),
          // copy the character to clipboard on single press
          onPressed: () {
            HandlePrediction().handlePress(context, widget.char);
          },
          
          // open prediction in the dictionary set in setting on long press
          onLongPress: () async {
            HandlePrediction().handleLongPress(context, widget.char);
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
    )
  );
  }
}
