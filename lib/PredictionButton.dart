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
          // handle a short press
          onPressed: () {
            HandlePrediction().handlePress(false, context, widget.char);
          },
          
          // handle a long press 
          onLongPress: () async {
            HandlePrediction().handlePress(true, context, widget.char);
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
