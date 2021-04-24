import 'DrawScreenShowcase.dart';
import 'KanjiBuffer.dart';
import 'globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'DaKanjiDrawer.dart';
import 'DrawingPainter.dart';
import 'PredictionButton.dart';
import 'KanjiBufferWidget.dart';


/// The "about"-screen.
/// 
/// Lets the user draw a kanji and than shows the most likely predictions.
/// Those can than be copied / opened in dictionaries by buttons.
class DrawScreen extends StatefulWidget {

  // init the tutorial of the draw screen
  final showcase = DrawScreenShowcase();

  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  // the DrawingPainter instance which defines the canvas to drawn on.
  DrawingPainter canvas;
  //the path which should be drawn on the canvas
  Path path = Path();

  // the size of the canvas widget
  double canvasSize;
  // initialize predictions with blank
  List<String> predictions = List.generate(10, (index) => " ");
  // save the context for the Showcase view
  BuildContext myContext;
  // widget in which character can be saved to look up words/sentences. 
  KanjiBuffer kanjiBuffer = KanjiBuffer();
  

  @override
  void initState() {
    super.initState();

    // always rebuild the ui when the kanji buffer changed
    kanjiBuffer.addListener(() {
      kanjiBuffer.runAnimation = true;
      setState(() { });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = (Theme.of(context).brightness == Brightness.dark);
    canvas = new DrawingPainter(path, darkMode);
    // init size of canvas and assure that it is min. 20 smaller than screen width
    canvasSize = MediaQuery.of(context).size.height * 3/6;
    if(canvasSize >= MediaQuery.of(context).size.width - 20)
      canvasSize = MediaQuery.of(context).size.width - 20;
    
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
                    
                    path.lineTo(point.dx, point.dy);
                  });
                },
                // started drawing
                onPanStart: (details) {
                  setState(() {
                    RenderBox renderBox = context.findRenderObject();
                    Offset point =
                      renderBox.globalToLocal(details.localPosition);
                    
                    path.moveTo(point.dx, point.dy);
                  });
                },
                // finished drawing a stroke
                onPanEnd: (details) async {
                  predictions = await canvas.runInference();
                  setState(() {});
                },
                child: CustomPaint(
                  painter: canvas,
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
                      if(path.computeMetrics().isNotEmpty){
                        path = () {
                          var p = path.computeMetrics().
                            take(path.computeMetrics().length - 1);
                          var newPath = Path();
                          p.forEach((element) {
                            newPath.addPath(element.extractPath(0, double.infinity), Offset.zero);
                          });
                          return newPath;
                        } ();
                        predictions = await canvas.runInference();
                      }
                      //else if(points.length == 1){
                      //  points.removeLast();
                      //  predictions = List.generate(10, (i) => " ");
                      //}
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
                    onPressed: () {
                      setState(() {
                        predictions = List.generate(10, (i) => " ");
                        path.reset();
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
                          path.reset();
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
