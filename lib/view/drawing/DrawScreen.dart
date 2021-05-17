import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get_it/get_it.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

import 'package:da_kanji_mobile/model/core/Screens.dart';
import 'package:da_kanji_mobile/model/core/DrawingInterpreter.dart';
import 'package:da_kanji_mobile/view/drawing/DrawScreenShowcase.dart';
import 'package:da_kanji_mobile/provider/KanjiBuffer.dart';
import 'package:da_kanji_mobile/provider/Strokes.dart';
import 'package:da_kanji_mobile/view/canvasSnappable.dart';
import 'package:da_kanji_mobile/view/DaKanjiDrawer.dart';
import 'package:da_kanji_mobile/view/drawing/DrawingPainter.dart';
import 'package:da_kanji_mobile/view/drawing//PredictionButton.dart';
import 'package:da_kanji_mobile/view/drawing/KanjiBufferWidget.dart';
import 'package:da_kanji_mobile/globals.dart';


/// The "draw"-screen.
/// 
/// Lets the user draw a kanji and than shows the most likely predictions.
/// Those can than be copied / opened in dictionaries by buttons.
class DrawScreen extends StatefulWidget
  with GetItStatefulWidgetMixin {

  // init the tutorial of the draw screen
  final showcase = DrawScreenShowcase();
  /// was this page opened by clicking on the tab in the drawer
  final bool openedByDrawer;

  DrawScreen(this.openedByDrawer);

  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen>
  with TickerProviderStateMixin, GetItStateMixin{
  /// the DrawingPainter instance which defines the canvas to drawn on.
  DrawingPainter _canvas;
  /// the size of the canvas widget
  double _canvasSize;
  /// global keys for running animations
  GlobalKey<CanvasSnappableState> _snappableKey;
  /// the ID of the pointer which is currently drawing
  int _pointerID;
  /// Keep track of if the pointer moved
  bool pointerMoved = false;
  /// Animation controller of the delete stroke animation
  AnimationController _deleteStrokeController;

  @override
  void initState() {
    super.initState();

    // initialize the global keys
    _snappableKey = GlobalKey<CanvasSnappableState>();

    // initialize the drawing interpreter
    GetIt.I<DrawingInterpreter>().init();

    // delete last stroke animation
    _deleteStrokeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200)
    );
    _deleteStrokeController.value = 1.0;
    _deleteStrokeController.addStatusListener((status) async {
      // when the last stroke delete animation finished 
      if(status == AnimationStatus.dismissed){
        _deleteStrokeController.value = 1.0;
        GetIt.I<Strokes>().removeLastStroke();
        if(GetIt.I<Strokes>().strokeCount > 0)
          GetIt.I<DrawingInterpreter>().runInference(
            await _canvas.getPNGListFromCanvas()
          );
        else
          GetIt.I<DrawingInterpreter>().clearPredictions();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = (Theme.of(context).brightness == Brightness.dark);
    // init size of canvas and assure that it is min. 20 smaller than screen width
    _canvasSize = MediaQuery.of(context).size.height * 3/6;
    if(_canvasSize >= MediaQuery.of(context).size.width - 20)
      _canvasSize = MediaQuery.of(context).size.width - 20;
    
    // add a listener to when the Navigator animation finished
    var route = ModalRoute.of(context);
    void handler(status) {
      if (status == AnimationStatus.completed) {
        route.animation.removeStatusListener(handler);
        
        if(SHOW_SHOWCASE_DRAWING){
          widget.showcase.init(context);
          widget.showcase.show();
        }
      }
    }
    route.animation.addStatusListener(handler);

    // GetItMixin watchers
    List<String> predictions =
      watchOnly((DrawingInterpreter d) => d.predictions);
    Path strokes = watchOnly((Strokes s) => s.path);
    String kanjiBuffer = watchOnly((KanjiBuffer k) => k.kanjiBuffer);


    return DaKanjiDrawer(
      currentScreen: Screens.drawing,
      animationAtStart: !widget.openedByDrawer,
      child: Center(
        child: Column( 
          children: [
            // the canvas to draw on
            Container(
              width: _canvasSize,
              height: _canvasSize,
              margin: EdgeInsets.fromLTRB(0, 
                (MediaQuery.of(context).size.width - _canvasSize) / 2, 
                0, 0),
              child: Listener(
                key: SHOWCASE_DRAWING[0].key,
                // started drawing
                onPointerDown: (details) {
                  // allow only one pointer at a time
                  if(_pointerID == null){
                    _pointerID = details.pointer;
                    setState(() {
                      // end the snapping animation when user starts drawing
                      if(_snappableKey.currentState.snapIsRunning())
                        _snappableKey.currentState.reset();

                      RenderBox renderBox = context.findRenderObject();
                      Offset point =
                        renderBox.globalToLocal(details.localPosition);
                      strokes.moveTo(point.dx, point.dy);
                    });
                  }
                },
                // drawing pointer moved
                onPointerMove: (details) {
                  // allow only one pointer at a time
                  if(_pointerID == details.pointer){
                    setState(() {
                      RenderBox renderBox = context.findRenderObject();
                      Offset point =
                        renderBox.globalToLocal(details.localPosition);
                      strokes.lineTo(point.dx, point.dy);
                    });
                    pointerMoved = true;
                  }
                },
                // finished drawing a stroke
                onPointerUp: (details) async {
                  if(pointerMoved){
                    get<DrawingInterpreter>().runInference(
                      await _canvas.getPNGListFromCanvas()
                    );
                    pointerMoved = false;
                    get<Strokes>().incrementStrokeCount();
                    setState(() { });
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
                    CanvasSnappable(
                      key: _snappableKey,
                      duration: Duration(milliseconds: 500),
                      child: AnimatedBuilder(
                        animation: _deleteStrokeController,
                        builder: (BuildContext context, Widget child){
                          _canvas = DrawingPainter(
                            strokes, darkMode, Size(_canvasSize, _canvasSize),
                            _deleteStrokeController.value
                          );
                          return CustomPaint(
                            size: Size(_canvasSize, _canvasSize),
                            painter: _canvas,
                          );
                        }
                      ),
                      snapColor:
                        Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      onSnapped: () {
                        _snappableKey.currentState.reset();
                      },
                    )
                  ],
                )
              )
            ),
            Spacer(),
            // undo/clear button and kanjiBuffer,
            Container(
              width: _canvasSize,
              child: Row(
                children: [
                  // undo
                  IconButton(
                    key: SHOWCASE_DRAWING[1].key,
                    icon: Icon(Icons.undo),
                    onPressed: () async {
                      // if animation is already running stop it
                      // and delete old stroke before deleting this stroke
                      if(_deleteStrokeController.status == AnimationStatus.reverse){
                        get<Strokes>().removeLastStroke();
                        _deleteStrokeController.value = 1.0;
                      } 
                      //only delete strokes if there are some left
                      if(get<Strokes>().strokeCount > 0)
                        _deleteStrokeController.reverse(from: 1.0);
                    }
                  ),
                  // multi character search input
                    Expanded(
                    child: Hero(
                      tag: "webviewHero_b_" + 
                        (kanjiBuffer == "" ? "Buffer" : kanjiBuffer),
                      child: Center(
                        key: SHOWCASE_DRAWING[6].key,
                        child: KanjiBufferWidget(_canvasSize)
                      )
                    ),
                  ),
                  // clear
                  IconButton(
                    key: SHOWCASE_DRAWING[2].key,
                    icon: Icon(Icons.clear),
                    onPressed: () async {
                      if(strokes.computeMetrics().isNotEmpty){
                        _snappableKey.currentState.snap(
                          await _canvas.getRGBAListFromCanvas(),
                          _canvasSize.floor(), _canvasSize.floor()
                        );

                        // wait before deleting the strokes to prevent stutter 
                        await Future.delayed(Duration(milliseconds: 50));
                        get<Strokes>().deleteAllStrokes();
                        get<DrawingInterpreter>().clearPredictions();
                      }
                    }
                  ), 
                ]
              ),
            ),
            // prediction buttons
            Container(
              key: SHOWCASE_DRAWING[3].key,
              width: _canvasSize,
              // approximated button height (width/5) * numRows + padding  
              height: (_canvasSize / 5.0) * 2.0 + 10, 
              child: GridView.count(
                physics: new NeverScrollableScrollPhysics(),
                crossAxisCount: 5,
                children: List.generate(10, (i) {
                  Widget widget = PredictionButton(predictions[i]);
                  // instantiate short/long press showcase button
                  if(i == 0){
                    widget = Container(
                      key: SHOWCASE_DRAWING[4].key,
                      child: widget 
                    );
                  }
                  return Hero(
                    tag: "webviewHero_" + 
                      (predictions[i] == " " ? i.toString() : predictions[i]),
                    child: widget,
                  );
                },
                )
              )
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
