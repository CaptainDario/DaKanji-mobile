import 'package:flutter/material.dart';

import 'HandlePredictions.dart';


/// A button which shows the given [char].
/// 
/// It can copy [char] to the clipboard or open it in a dictionary.
class PredictionButton extends StatelessWidget {
  
  final String char;


  PredictionButton({this.char});


  @override
  Widget build(BuildContext context){
  return Transform.scale(
    scale: 0.9, 
    child: AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        child: ElevatedButton(
           
          // handle a short press
          onPressed: () {
            HandlePrediction().handlePress(false, context, char);
          },
          
          // handle a long press 
          onLongPress: () async {
            HandlePrediction().handlePress(true, context, char);
          },
          child: FittedBox(
            child: Text(
              char,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 1000.0,
              ),
            )
          )
        )
      )
    )
  );
  }
}
