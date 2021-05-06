import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'package:da_kanji_mobile/provider/KanjiBuffer.dart';
import 'package:da_kanji_mobile/model/helper/HandlePredictions.dart';



/// A draggable `OutlinedButton` that moves back to `Alignment.center` when it's
/// released.
class KanjiBufferWidget extends StatefulWidget {
  final KanjiBuffer kanjiBuffer;
  final double canvasSize;

  KanjiBufferWidget(this.kanjiBuffer, this.canvasSize);

  @override
  _KanjiBufferWidgetState createState() => _KanjiBufferWidgetState();
}

class _KanjiBufferWidgetState extends State<KanjiBufferWidget>
    with TickerProviderStateMixin {

  AnimationController _springController;

  /// The alignment of the card as it is dragged or being animated.
  ///
  /// While the card is being dragged, this value is set to the values computed
  /// in the GestureDetector onPanUpdate callback. If the animation is running,
  /// this value is set to the value of the [_springAnimation].
  Alignment _dragAlignment = Alignment.center;
  bool deletedWithSwipe = false;

  Animation<Alignment> _springAnimation;
  
  // animation and controller for the delete-chars-rotation of the kanji buffer
  int _rotationXDuration = 1000;
  AnimationController _rotationXController;
  Animation<double> _rotationXAnimation;

  // animation when character added to kanjibuffer
  int _scaleInNewCharDuration = 250; 
  AnimationController _scaleInNewCharController;
  Animation<double> _scaleInNewCharAnimation;

  // size of the kanji buffer
  double width;

  int charactersFit = 0;
  
  

  /// Calculates and runs a [SpringSimulation].
  void _runAnimation(Offset pixelsPerSecond, Size size) {
    _springAnimation = _springController.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: Alignment.center,
      ),
    );
    // Calculate the velocity relative to the unit interval, [0,1],
    // used by the animation controller.
    final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;

    const spring = SpringDescription(
      mass: 60,
      stiffness: 0.01,
      damping: 1,
    );

    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    _springController.animateWith(simulation);
  }

  @override
  void initState() {
    super.initState();
    
    // controller / animation of swipe left gesture
    _springController = AnimationController(vsync: this);
    _springController.addListener(() {
      setState(() {
        _dragAlignment = _springAnimation.value;
      });
    });

    // initialize the animation / controller of the delete characters animation
    _rotationXController = AnimationController(
      duration: Duration(milliseconds: _rotationXDuration),
      vsync: this,
    );
    _rotationXAnimation = CurvedAnimation(
      parent: _rotationXController,
      curve: Curves.elasticOut
    );
    
    // controller / animation of the character added animation
    _scaleInNewCharController = AnimationController(
      duration: Duration(milliseconds: _scaleInNewCharDuration),
      vsync: this,
    );
    _scaleInNewCharAnimation = new Tween(
      begin: 0.1,
      end: 1.0,
    ).animate(new CurvedAnimation(
      parent: _scaleInNewCharController,
      curve: Curves.easeOut,
    ));
  
    // set width of the kanjibuffer
    width = () {
      double margin = 10;
      double buttonSize = (widget.canvasSize - 4.0 * margin) / 5;
      return (buttonSize * 3) + (3 * margin);
    }();

    // get the maximum no of characters which fit in the kanji buffer
    charactersFit = -3;
    String chars = "口口";
    double w = 1;
    while(width > w){
      w = (TextPainter(
        text: TextSpan(text: chars),
        maxLines: 1,
        textScaleFactor: 1.5,
        textDirection: TextDirection.ltr)
      ..layout()).size.width;

      chars += "口";
      charactersFit += 1;
    }

  }

  @override
  void dispose() {
    _springController.dispose();
    _rotationXController.dispose();
    _scaleInNewCharController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if(widget.kanjiBuffer.runAnimation){
      _scaleInNewCharController.forward(from: 0.0);
      widget.kanjiBuffer.runAnimation = false;
    }
    return GestureDetector(
      onPanDown: (details) {
        _springController.stop();
      },
      // animate dragging the widget
      onPanUpdate: (details) {
        setState(() {
          _dragAlignment += Alignment(
            max(min(details.delta.dx / (size.height / 2), 0), -0.05),
            0
          );
          // delete the last char if drag over the threshold
          if(_dragAlignment.x < -0.03 && !deletedWithSwipe &&
            widget.kanjiBuffer.kanjiBuffer.length > 0){

            // if the delete animation is already running delete the character
            // of the old animation
            if(_scaleInNewCharController.status == AnimationStatus.reverse)
              widget.kanjiBuffer.removeLastChar();

            // run the animation in reverse and at the end delete the char
            _scaleInNewCharController.reverse();
            Future.delayed(
              Duration(milliseconds: (_scaleInNewCharDuration).round()),
              () { 
                _scaleInNewCharController.stop();
                _scaleInNewCharController.value = 1.0;
                widget.kanjiBuffer.removeLastChar();
              }
             );
            deletedWithSwipe = true;
          }
        });
      },
      // run the animation to move the widget back to the center
      onPanEnd: (details) {
        _runAnimation(details.velocity.pixelsPerSecond, size);
        deletedWithSwipe = false;
      },
      // empty on double press
      onDoubleTap: () {
        // start the delete animation if there are characters in the buffer
        if(widget.kanjiBuffer.kanjiBuffer.length > 0){
          _rotationXController.forward(from: 0.0);

          //delete the characters after the animation
          Future.delayed(Duration(milliseconds: (_rotationXDuration/8).round()), (){
            setState(() {
               widget.kanjiBuffer.kanjiBuffer = "";           
            });
          });
        }
      },
      child: Align(
        alignment: _dragAlignment,
        child: AnimatedBuilder(
            animation:  _rotationXAnimation,
            child: Container(
            // make the multi character bar the same size as 3 prediction-buttons
            width: width,
            padding: EdgeInsets.all(5),
            child: OutlinedButton(
              // copy to clipboard and show snackbar
              onPressed: (){
                HandlePrediction()
                  .handlePress(false, context, widget.kanjiBuffer.kanjiBuffer); 
              },
              // open with dictionary on long press
              onLongPress: (){
                HandlePrediction()
                  .handlePress(true, context, widget.kanjiBuffer.kanjiBuffer); 
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    () { 
                      int length = widget.kanjiBuffer.kanjiBuffer.length;
                      
                      // more than one character is in the kanjibuffer
                      if(length > 1){
                        // more character in the buffer than can be shown
                        if(widget.kanjiBuffer.kanjiBuffer.length > charactersFit)
                          return "…" +  widget.kanjiBuffer.kanjiBuffer
                            .substring(length-charactersFit, length-1);
                        // whole buffer can be shown
                        else{
                          return widget.kanjiBuffer.kanjiBuffer.substring(0, length-1);
                        }
                      }
                      else
                        return "";
                    } (),
                    textScaleFactor: 1.5,
                    softWrap: false,
                  ),
                  ScaleTransition(
                    scale: _scaleInNewCharAnimation,
                    child: Text(
                      () {
                        int length = widget.kanjiBuffer.kanjiBuffer.length;
                        if(length > 0)
                          return widget.kanjiBuffer.kanjiBuffer[length - 1];
                        else
                          return "";
                      } (),
                      textScaleFactor: 1.5,
                    )
                  )
                ]
              )
            ),
          ),
          // builder for spinning (delete) animation
          builder: (BuildContext context, Widget child){
            return Transform(
              transform: () { 
                Matrix4 transform = Matrix4.identity();
                transform *=
                  Matrix4.rotationX(_rotationXAnimation.value * 2 * pi);
                return transform;
              } (),
              alignment: Alignment.center,
              child: child,
            );
          },
        )
      ),
    );
  }
}
