import 'package:flutter/widgets.dart';

import 'package:get_it/get_it.dart';

import 'package:da_kanji_mobile/model/core/DrawingInterpreter.dart';
import 'package:da_kanji_mobile/provider/Strokes.dart';
import 'package:da_kanji_mobile/view/drawing/DrawingPainter.dart';
import 'package:get_it_mixin/get_it_mixin.dart';



class DrawingCanvas extends StatefulWidget 
  with GetItStatefulWidgetMixin {

  /// the width of the DrawingCanvas 
  final double width;
  /// the height of the DrawingCanvas 
  final double height;
  /// the margins around the DrawingCanvas 
  final EdgeInsets margin;
  /// the Strokes which should be drawn on the canvas
  final Strokes strokes;

  final VoidCallback finishedDrawing;

  final VoidCallback deletedLastStroke;

  final VoidCallback deletedAllStrokes;


  DrawingCanvas({
    @required this.width,
    @required this.height,
    @required this.strokes,
    this.margin,
    Key key,
    this.finishedDrawing,
    this.deletedLastStroke,
    this.deletedAllStrokes
  }) : super(key: key);

  @override
  _DrawingCanvasState createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas>
  with TickerProviderStateMixin, GetItStateMixin {
  
  /// the DrawingPainter instance which defines the canvas to drawn on.
  DrawingPainter _canvas;
  /// the ID of the pointer which is currently drawing
   int _pointerID;
  /// Keep track of if the pointer moved
  bool pointerMoved = false;
  /// Animation controller of the delete stroke animation
  AnimationController _canvasController;

  bool darkMode = false;
    


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
        
        // if all strokes should be deleted
        if(widget.strokes.deletingAllStrokes){
          widget.strokes.deleteAllStrokes();
          if(widget.deletedAllStrokes != null)
            widget.deletedAllStrokes();
        }
        // or only the last one
        else{
          widget.strokes.deleteLastStroke();
          if(widget.deletedLastStroke != null)
            widget.deletedLastStroke();
        }
        _canvasController.value = 1.0;
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
            setState(() {
              Offset point = details.localPosition;
              widget.strokes.path.moveTo(point.dx, point.dy);
            });
          }
        },
        // drawing pointer moved
        onPointerMove: (details) {
          // allow only one pointer at a time
          if(_pointerID == details.pointer){
            setState(() {
              Offset point = details.localPosition;
              widget.strokes.path.lineTo(point.dx, point.dy);
            });
            pointerMoved = true;
          }
        },
        // finished drawing a stroke
        onPointerUp: (details) async {
          if(pointerMoved){
            if(widget.finishedDrawing != null)
              widget.finishedDrawing();
            pointerMoved = false;
            widget.strokes.incrementStrokeCount();

            if(widget.finishedDrawing != null)
              widget.finishedDrawing();
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
}