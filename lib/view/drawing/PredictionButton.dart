import 'package:flutter/material.dart';

import 'package:da_kanji_mobile/model/helper/HandlePredictions.dart';


/// A button which shows the given [char].
/// 
/// It can copy [char] to the clipboard or open it in a dictionary.
class PredictionButton extends StatefulWidget {

  
  final String char;
  final void Function() tapFunction;
  PredictionButton (this.char, this.tapFunction);
  
  @override
  _PredictionButtonState createState() => _PredictionButtonState();
}

class _PredictionButtonState extends State<PredictionButton>
  with TickerProviderStateMixin{
    
  AnimationController controller;
  Animation<double> animation;

  void anim(){
   controller.forward(from: 0.0); 
  }

  @override
  void initState() { 
    super.initState();
    
    controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    animation = new Tween(
      begin: 1.0,
      end: 1.05,
    ).animate(new CurvedAnimation(
      parent: controller,
      curve: Curves.decelerate,
    ));

    // run the animation always reversed after completion 
    animation.addStatusListener((status) {
      if(status == AnimationStatus.completed)
        controller.reverse();
    });
  }

  @override
  void dispose() { 
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
  return ScaleTransition(
    scale: animation, 
    child: Transform.scale(
        scale: 0.9,
        child: AspectRatio(
        aspectRatio: 1,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,

          onDoubleTap: () {
            controller.forward(from: 0.0);
            widget.tapFunction();
          },

          child: ElevatedButton(
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
                style: TextStyle(
                  fontSize: 60,
                ),
              )
            )
          )
        )
      )
    )
  );
  }
}
