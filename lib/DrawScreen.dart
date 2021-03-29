import 'DrawScreenShowcase.dart';
import 'KanjiBuffer.dart';
import 'globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'DaKanjiRecognizerDrawer.dart';
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
  //the points which were drawn on the canvas
  List<List<Offset>> points = [];
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

    // when the screen was built
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // only show the showcase at an update/new install
      if(SHOW_SHOWCASE_DRAWING){
        widget.showcase.init(context);
        widget.showcase.show();
      }
    });

    // always rebuild the ui when the kanji buffer changed
    kanjiBuffer.addListener(() {
      setState(() { });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = (Theme.of(context).brightness == Brightness.dark);
    canvas = new DrawingPainter(points, darkMode);
    // init size of canvas and assure that it is min. 20 smaller than screen width
    canvasSize = MediaQuery.of(context).size.height * 3/6;
    if(canvasSize >= MediaQuery.of(context).size.width - 20)
      canvasSize = MediaQuery.of(context).size.width - 20;

    return Scaffold(
      key: DRAWER_KEY,
      appBar: AppBar(
        title: Text("Drawing"),
      ),
      drawer: DaKanjiRecognizerDrawer(),
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
                    points[points.length - 1].add(point);
                  });
                },
                // started drawing
                onPanStart: (details) {
                  setState(() {
                    points.add([]);
                    RenderBox renderBox = context.findRenderObject();
                    Offset point =
                        renderBox.globalToLocal(details.localPosition);
                    points[points.length - 1].add(point);
                  });
                },
                // finished drawing a stroke
                onPanEnd: (details) async {
                  // remove single points and don't run inference for them
                  if (points[points.length - 1].length == 1)
                    points.removeLast();
                  else
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
                      if(points.length > 1){
                        points.removeLast();
                        predictions = await canvas.runInference();
                      }
                      else{
                        points.removeLast();
                        predictions = List.generate(10, (i) => " ");
                      }
                      setState(() {});
                    }
                  ),
                  // multi character search input
                  Expanded(
                      child: Center(
                        key: SHOWCASE_DRAWING[6].key,
                        child: KanjiBufferWidget(
                          canvasSize: canvasSize,
                          kanjiBuffer: kanjiBuffer,
                        ),
                      )
                    //),
                  ),
                  // clear
                  IconButton(
                    key: SHOWCASE_DRAWING[2].key,
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        predictions = List.generate(10, (i) => " ");
                        points.clear();
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
                  var ret;
                  // instantiate short/long press showcase button
                  if(i == 0){
                    ret = Container(
                      key: SHOWCASE_DRAWING[4].key,
                      child: PredictionButton(
                        char: predictions[i],
                      )
                    );
                  }
                  // instantiate the other buttons
                  else ret = PredictionButton(char: predictions[i]);
                  
                  return GestureDetector(
                    child: ret,
                    onDoubleTap: (){
                      setState(() {
                        if(SETTINGS.emptyCanvasAfterDoubleTap)
                          points.clear();
                        kanjiBuffer.kanjiBuffer += predictions[i];
                      });
                    },
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
