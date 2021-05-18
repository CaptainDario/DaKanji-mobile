import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:da_kanji_mobile/provider/Strokes.dart';
import 'package:da_kanji_mobile/view/drawing/DrawingPainter.dart';



class DrawingCanvas extends StatefulWidget {

  /// the width of the DrawingCanvas 
  final double width;
  /// the height of the DrawingCanvas 
  final double height;
  /// the margins around the DrawingCanvas 
  final EdgeInsets margin;
  /// the Strokes which should be drawn on the canvas
  final Strokes strokes;
  /// is invoked once a stroke was drawn (pointerUp)
  /// 
  /// Provides the current image of the canvas as parameter
  final void Function(Uint8List image) onFinishedDrawing;
  /// is invoked when the delete last stroke animation finished
  /// 
  /// Provides the current image of the canvas as parameter
  final void Function(Uint8List image) onDeletedLastStroke;
  /// is invoked when the delete all strokes animation finished
  /// 
  /// Provides the current image of the canvas as parameter
  final void Function(Uint8List image) onDeletedAllStrokes;


  DrawingCanvas({
    @required this.width,
    @required this.height,
    @required this.strokes,
    this.margin,
    Key key,
    this.onFinishedDrawing,
    this.onDeletedLastStroke,
    this.onDeletedAllStrokes
  }) : super(key: key);

  @override
  _DrawingCanvasState createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> 
  with TickerProviderStateMixin {
  
  /// the DrawingPainter instance which defines the canvas to drawn on.
  DrawingPainter _canvas;
  /// the ID of the pointer which is currently drawing
   int _pointerID;
  /// Keep track of if the pointer moved
  bool pointerMoved = false;
  /// Animation controller of the delete stroke animation
  AnimationController _canvasController;
  /// should the app run in dark mode.
  bool darkMode;
    


  @override
  void initState() { 
    super.initState();
    // delete last stroke / clear canvas animation
    _canvasController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200)
    );
    _canvasController.value = 1.0;
    _canvasController.addStatusListener((status) async {
      // when the animation finished 
      if(status == AnimationStatus.dismissed){
        
        _canvasController.value = 1.0;
        // if all strokes should be deleted
        if(widget.strokes.deletingAllStrokes){
          widget.strokes.deleteAllStrokes();

          if(widget.onDeletedAllStrokes != null)
            widget.onDeletedAllStrokes(await getPNGImage());
        }
        // or only the last one
        else{
          widget.strokes.deleteLastStroke();

          if(widget.onDeletedLastStroke != null)
            widget.onDeletedLastStroke(await getPNGImage());
        }
      }
    });
  
  }

  @override
  Widget build(BuildContext context) {

    // animate deleting the last stroke
    if(widget.strokes.deletingLastStroke){
      if(_canvasController.isAnimating)
        widget.strokes.deleteLastStroke();

      _canvasController.reverse(from: 1.0);
    }
    //
    if(widget.strokes.deletingAllStrokes && !_canvasController.isAnimating){
      _canvasController.reverse(from: 1.0);
    }

    darkMode = (Theme.of(context).brightness == Brightness.dark);

    return Container(
      height: widget.height,
      width: widget.width,
      margin: widget.margin,
      child: Listener(
        // started drawing
        onPointerDown: (details) {
          // allow only one pointer at a time
          if(_pointerID == null){
            _pointerID = details.pointer;
            Offset point = details.localPosition;
            widget.strokes.moveTo(point.dx, point.dy);
          }
        },
        // drawing pointer moved
        onPointerMove: (details) {
          // allow only one pointer at a time
          if(_pointerID == details.pointer){
            Offset point = details.localPosition;
            widget.strokes.lineTo(point.dx, point.dy);
            pointerMoved = true;
          }
        },
        // finished drawing a stroke
        onPointerUp: (details) async {
          if(pointerMoved){
            pointerMoved = false;
            widget.strokes.incrementStrokeCount();

            if(widget.onFinishedDrawing != null){
              widget.onFinishedDrawing(await getPNGImage());
            }
          }
          // mark this pointer as removed
          _pointerID = null;
        },
        child: Stack(
          children: [
            Image(image: 
              AssetImage(darkMode
                ? "assets/kanji_drawing_aid_w.png"
                : "assets/kanji_drawing_aid_b.png")
            ),
            AnimatedBuilder(
              animation: _canvasController,
              builder: (BuildContext context, Widget child){
                _canvas = DrawingPainter(
                  widget.strokes.path, 
                  darkMode, Size(widget.width, widget.height),
                  _canvasController.value
                );
                Widget canvas = CustomPaint(
                    size: Size(widget.width, widget.height),
                    painter: _canvas,
                );

                if(widget.strokes.deletingAllStrokes)
                  return Opacity(
                    opacity: _canvasController.value,
                    child: canvas
                  );
                else 
                  return canvas;
              }
            ),
          ],
        )
      ),
    );
  }

  /// convenience wrapper for getting a PNG-image as list of the current canvas.
  Future<Uint8List> getPNGImage() async {
    return _canvas.getPNGListFromCanvas();
  } 
  
  /// convenience wrapper for getting a RGBA-list of the current canvas.
  Future<Uint8List> getRGBAImage() async {
    return _canvas.getRGBAListFromCanvas();
  } 

}