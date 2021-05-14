import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get_it/get_it.dart';

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
class DrawScreen extends StatefulWidget {

  // init the tutorial of the draw screen
  final showcase = DrawScreenShowcase();
  /// was this page opened by clicking on the tab in the drawer
  final bool openedByDrawer;

  DrawScreen(this.openedByDrawer);

  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> with TickerProviderStateMixin{
  /// the DrawingPainter instance which defines the canvas to drawn on.
  DrawingPainter _canvas;
  /// the size of the canvas widget
  double _canvasSize;
  /// global keys for running animations
  GlobalKey<CanvasSnappableState> _snappableKey;
  /// the ID of the pointer which is currently drawing
  int _pointerID;
  ///
  AnimationController _canvasController;

  @override
  void initState() {
    super.initState();

    // initialize the global keys
    _snappableKey = GlobalKey<CanvasSnappableState>();

    // always rebuild the ui when the kanji buffer changed
    GetIt.I<KanjiBuffer>().addListener(() {
      GetIt.I<KanjiBuffer>().runAnimation = true;
    });
    // initialize the drawing interpreter
    GetIt.I<DrawingInterpreter>().init();

    _canvasController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200)
    );
    _canvasController.value = 1.0;
    _canvasController.addStatusListener((status) {
      if(status == AnimationStatus.dismissed){
        GetIt.I<Strokes>().removeLastStroke();
        _canvasController.value = 1.0;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    GetIt.I<DrawingInterpreter>().free();
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
                // drawing pointer moved
                onPointerMove: (details) {
                  // allow only one pointer at a time
                  if(_pointerID == details.pointer){
                    setState(() {
                      RenderBox renderBox = context.findRenderObject();
                      Offset point =
                        renderBox.globalToLocal(details.localPosition);
                      GetIt.I<Strokes>().path.lineTo(point.dx, point.dy);
                    });
                  }
                },
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
                      GetIt.I<Strokes>().path.moveTo(point.dx, point.dy);
                    });
                  }
                },
                // finished drawing a stroke
                onPointerUp: (details) async {
                  GetIt.I<DrawingInterpreter>().runInference(
                    await _canvas.getPNGListFromCanvas()
                  );
                  // mark this pointer as removed
                  _pointerID = null;
                  setState(() {});
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
                        animation: _canvasController,
                        builder: (BuildContext context, Widget child){
                          _canvas = DrawingPainter(
                            GetIt.I<Strokes>().path, darkMode, 
                            Size(_canvasSize, _canvasSize),
                            _canvasController.value
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
                      int strokes = GetIt.I<Strokes>().path.computeMetrics().length;

                      // if animation is already running stop it
                      // and delete old stroke before deleting this stroke
                      if(_canvasController.status == AnimationStatus.reverse){
                        GetIt.I<Strokes>().removeLastStroke();
                        _canvasController.value = 1.0;
                      } 

                      //only run inference if canvas still has strokes
                      if(strokes >= 1){
                         _canvasController.reverse(from: 1.0);
                        GetIt.I<DrawingInterpreter>().runInference(
                          await _canvas.getPNGListFromCanvas()
                        ); 
                      }
                      if(strokes == 0){
                        GetIt.I<DrawingInterpreter>().clearPredictions(); 
                      }
                      setState(() {});
                    }
                  ),
                  // multi character search input
                    Expanded(
                    child: Hero(
                      tag: "webviewHero_b_" + 
                          (GetIt.I<KanjiBuffer>().kanjiBuffer == "" ? 
                          "Buffer" : GetIt.I<KanjiBuffer>().kanjiBuffer),
                        child: Center(
                          key: SHOWCASE_DRAWING[6].key,
                          child: KanjiBufferWidget(_canvasSize)
                        )
                      //),
                    ),
                  ),
                  // clear
                  IconButton(
                    key: SHOWCASE_DRAWING[2].key,
                    icon: Icon(Icons.clear),
                    onPressed: () async {
                      if(GetIt.I<Strokes>().path.computeMetrics().isNotEmpty){
                        _snappableKey.currentState.snap(
                          await _canvas.getRGBAListFromCanvas(),
                          _canvasSize.floor(), _canvasSize.floor()
                        );
                        setState(() {
                          GetIt.I<DrawingInterpreter>().clearPredictions(); 
                        });
                        
                        await Future.delayed(Duration(milliseconds: 50));
                        GetIt.I<Strokes>().deleteAllStrokes();
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
                  Widget widget = PredictionButton(
                    GetIt.I<DrawingInterpreter>().predictions[i]
                  );
                  // instantiate short/long press showcase button
                  if(i == 0){
                    widget = Container(
                      key: SHOWCASE_DRAWING[4].key,
                      child: widget 
                    );
                  }
                  return Hero(
                    tag: "webviewHero_" + 
                      (GetIt.I<DrawingInterpreter>().predictions[i] == " "
                      ? i.toString()
                      : GetIt.I<DrawingInterpreter>().predictions[i]),
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
