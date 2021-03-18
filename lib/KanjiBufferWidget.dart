import 'dart:math';

import 'package:da_kanji_recognizer_mobile/HandlePredictions.dart';
import 'package:da_kanji_recognizer_mobile/KanjiBuffer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';



/// A draggable card that moves back to [Alignment.center] when it's
/// released.
class KanjiBufferWidget extends StatefulWidget {
  final KanjiBuffer kanjiBuffer;
  final double canvasSize;

  KanjiBufferWidget({this.kanjiBuffer, this.canvasSize});

  @override
  _KanjiBufferWidgetState createState() => _KanjiBufferWidgetState();
}

class _KanjiBufferWidgetState extends State<KanjiBufferWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  /// The alignment of the card as it is dragged or being animated.
  ///
  /// While the card is being dragged, this value is set to the values computed
  /// in the GestureDetector onPanUpdate callback. If the animation is running,
  /// this value is set to the value of the [_animation].
  Alignment _dragAlignment = Alignment.center;
  bool deletedWithSwipe = false;

  Animation<Alignment> _animation;

  /// Calculates and runs a [SpringSimulation].
  void _runAnimation(Offset pixelsPerSecond, Size size) {
    _animation = _controller.drive(
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

    _controller.animateWith(simulation);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    _controller.addListener(() {
      setState(() {
        _dragAlignment = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onPanDown: (details) {
        _controller.stop();
      },
      // animate dragging the widget
      onPanUpdate: (details) {
        setState(() {
          _dragAlignment += Alignment(
            max(min(details.delta.dx / (size.height / 2), 0), -0.005),
            0
          );
          if(_dragAlignment.x < -0.03 && !deletedWithSwipe &&
            widget.kanjiBuffer.kanjiBuffer.length > 0){
            widget.kanjiBuffer.removeLastChar();
            deletedWithSwipe = true;
          }
        });
      },
      // run the animation to move the widget back to the center
      onPanEnd: (details) {
        _runAnimation(details.velocity.pixelsPerSecond, size);
        deletedWithSwipe = false;
      },
      onLongPress: () { 
      },
      // empty on double press
      onDoubleTap: () { 
        setState(() {
          widget.kanjiBuffer.kanjiBuffer = "";
        });
      },
      child: Align(
        alignment: _dragAlignment,
        child: Container(
          // make the multi character bar the same size as 3 prediction-buttons
          width: () {
            double margin = 10;
            double buttonSize = (widget.canvasSize - 4.0 * margin) / 5;
            return (buttonSize * 3) + (3 * margin);
          }(),
          padding: EdgeInsets.all(5),
          child: MaterialButton(
            color: Colors.blue,
            // copy to clipboard and show snackbar
            onPressed: (){
              HandlePrediction().handlePress(context, widget.kanjiBuffer.kanjiBuffer); 
            },
            // open with dictionary on long press
            onLongPress: (){
              HandlePrediction().handleLongPress(context, widget.kanjiBuffer.kanjiBuffer); 
            },
            child: Text(
              widget.kanjiBuffer.kanjiBuffer,
              textScaleFactor: 1.5,
              softWrap: false,
            )
          ),
        )
      ),
    );
  }
}
