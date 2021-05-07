import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get_it/get_it.dart';

import 'package:da_kanji_mobile/model/core/DrawingInterpreter.dart';
import 'package:da_kanji_mobile/view/drawing/DrawScreenShowcase.dart';
import 'package:da_kanji_mobile/provider/KanjiBuffer.dart';
import 'package:da_kanji_mobile/provider/Strokes.dart';
import 'package:da_kanji_mobile/provider/Settings.dart';
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

  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> with TickerProviderStateMixin{
  // the DrawingPainter instance which defines the canvas to drawn on.
  DrawingPainter canvas;
  // the size of the canvas widget
  double canvasSize;
  // save the context for the Showcase view
  BuildContext myContext;
  // global keys for running animations
  GlobalKey<CanvasSnappableState> snappableKey;


  @override
  void initState() {
    super.initState();

    // initialize the global keys
    snappableKey = GlobalKey<CanvasSnappableState>();

    // always rebuild the ui when the kanji buffer changed
    GetIt.I<KanjiBuffer>().addListener(() {
      GetIt.I<KanjiBuffer>().runAnimation = true;
      setState(() { });
    });

    // initialize the drawing interpreter
    GetIt.I<DrawingInterpreter>().init();
  }

  @override
  void dispose() { 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = (Theme.of(context).brightness == Brightness.dark);
    // init size of canvas and assure that it is min. 20 smaller than screen width
    canvasSize = MediaQuery.of(context).size.height * 3/6;
    if(canvasSize >= MediaQuery.of(context).size.width - 20)
      canvasSize = MediaQuery.of(context).size.width - 20;
    canvas = new DrawingPainter(
      GetIt.I<Strokes>().path,
      darkMode,
      Size(canvasSize, canvasSize),
    );
    
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

    return Scaffold(
      key: DRAWER_KEY,
      appBar: AppBar(
        title: Text("Drawing"),
      ),
      drawer: DaKanjiDrawer(),
      body:
      Center(
          child: Column( 
            children: [
              // the canvas to draw on
              Container(
                width: canvasSize,
                height: canvasSize,
                margin: EdgeInsets.fromLTRB(0, 
                  (MediaQuery.of(context).size.width - canvasSize) / 2, 
                  0, 0),
                  child: GestureDetector(
                    key: SHOWCASE_DRAWING[0].key,
                    // drawing pointer moved
                    onPanUpdate: (details) {
                      setState(() {
                        RenderBox renderBox = context.findRenderObject();
                        Offset point =
                          renderBox.globalToLocal(details.localPosition);
                        GetIt.I<Strokes>().path.lineTo(point.dx, point.dy);
                      });
                    },
                    // started drawing
                    onPanStart: (details) {
                      setState(() {
                        // end the snapping animation when user starts drawing
                        if(snappableKey.currentState.snapIsRunning())
                          snappableKey.currentState.reset();

                        RenderBox renderBox = context.findRenderObject();
                        Offset point =
                          renderBox.globalToLocal(details.localPosition);
                        GetIt.I<Strokes>().path.moveTo(point.dx, point.dy);
                      });
                    },
                    // finished drawing a stroke
                    onPanEnd: (details) async {
                      GetIt.I<DrawingInterpreter>().runInference(
                        await canvas.getPNGListFromCanvas()
                      );
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
                          key: snappableKey,
                          duration: Duration(milliseconds: 500),
                          child: CustomPaint(
                            size: Size(canvasSize, canvasSize),
                            painter: canvas,
                          ),
                          snapColor: GetIt.I<Settings>().selectedThemeMode() 
                            == ThemeMode.dark
                            ? Colors.white
                            : Colors.black,
                          onSnapped: () {
                            snappableKey.currentState.reset();
                          },
                        )
                      ],
                    ),
                  ),
              ),
              Spacer(),
              // undo/clear button and kanjiBuffer,
              Container(
                width: canvasSize,
                child: Row(
                  children: [
                    // undo
                    IconButton(
                      key: SHOWCASE_DRAWING[1].key,
                      icon: Icon(Icons.undo),
                      onPressed: () async {
                        //only run inference if canvas still has strokes
                        if(GetIt.I<Strokes>().path.computeMetrics().isNotEmpty){
                          GetIt.I<Strokes>().removeLastStroke();
                          GetIt.I<DrawingInterpreter>().runInference(
                            await canvas.getPNGListFromCanvas()
                          ); 
                        }
                        if(GetIt.I<Strokes>().path.computeMetrics().isEmpty){
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
                            child: KanjiBufferWidget(canvasSize)
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
                          snappableKey.currentState.snap(
                            await canvas.getRGBAListFromCanvas(),
                            canvasSize.floor(), canvasSize.floor()
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
                width: canvasSize,
                // approximated button height (width/5) * numRows + padding  
                height: (canvasSize / 5.0) * 2.0 + 10, 
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
      )
    );
  }
  


}
