import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get_it/get_it.dart';
import 'canvasSnappable.dart';

import 'Strokes.dart';
import 'DrawScreenShowcase.dart';
import 'KanjiBuffer.dart';
import 'globals.dart';
import 'DaKanjiDrawer.dart';
import 'DrawingPainter.dart';
import 'PredictionButton.dart';
import 'KanjiBufferWidget.dart';


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
  // initialize predictions with blank
  List<String> predictions = List.generate(10, (index) => " ");
  // save the context for the Showcase view
  BuildContext myContext;
  // widget in which character can be saved to look up words/sentences. 
  KanjiBuffer kanjiBuffer = KanjiBuffer();
  // global keys for running animations
  GlobalKey<SnappableState> snappableKey;


  @override
  void initState() {
    super.initState();

    // initialize the global keys
    snappableKey = GlobalKey<SnappableState>();

    // always rebuild the ui when the kanji buffer changed
    kanjiBuffer.addListener(() {
      kanjiBuffer.runAnimation = true;
      setState(() { });
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
      body: Center(
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
                        RenderBox renderBox = context.findRenderObject();
                        Offset point =
                          renderBox.globalToLocal(details.localPosition);
                        
                        GetIt.I<Strokes>().path.moveTo(point.dx, point.dy);
                      });
                    },
                    // finished drawing a stroke
                    onPanEnd: (details) async {
                      predictions = await canvas.runInference();
                      setState(() {});
                    },
                    child: Stack(
                      children: [
                        Image(image: 
                          AssetImage(darkMode
                            ? "assets/kanji_drawing_aid_w.png"
                            : "assets/kanji_drawing_aid_b.png")
                        ),
                        Snappable(
                          key: snappableKey,
                          child: CustomPaint(
                            size: Size(canvasSize, canvasSize),
                            painter: canvas,
                          ),
                          onSnapped: () {
                            GetIt.I<Strokes>().deleteAllStrokes();
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
                          predictions = await canvas.runInference();
                        }
                        if(GetIt.I<Strokes>().path.computeMetrics().isEmpty){
                          predictions = List.generate(10, (i) => " ");
                        }
                        setState(() {});
                      }
                    ),
                    // multi character search input
                      Expanded(
                      child: Hero(
                        tag: "webviewHero_" + 
                            (kanjiBuffer.kanjiBuffer == "" ? 
                            "Buffer" : kanjiBuffer.kanjiBuffer),
                          child: Center(
                            key: SHOWCASE_DRAWING[6].key,
                            child: KanjiBufferWidget(kanjiBuffer, canvasSize)
                          )
                        //),
                      ),
                    ),
                    // clear
                    IconButton(
                      key: SHOWCASE_DRAWING[2].key,
                      icon: Icon(Icons.clear),
                      onPressed: () async {
                        snappableKey.currentState.snap(
                          await canvas.getRGBAListFromCanvas(),
                          canvasSize.floor(),
                          canvasSize.floor()
                        );
                        setState(() {
                          predictions = List.generate(10, (i) => " ");
                        });
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
                      predictions[i],
                      () {
                        setState(() {
                          if(SETTINGS.emptyCanvasAfterDoubleTap)
                            GetIt.I<Strokes>().deleteAllStrokes(); 
                          kanjiBuffer.kanjiBuffer += predictions[i];
                        });
                      }
                    );
                    // instantiate short/long press showcase button
                    if(i == 0){
                      widget = Container(
                        key: SHOWCASE_DRAWING[4].key,
                        child: widget 
                      );
                    }
                    return Hero(
                      tag: "webviewHero_" + (predictions[i] == " " ? 
                        i.toString() : predictions[i]),
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
