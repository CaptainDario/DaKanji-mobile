import 'package:da_kanji_recognizer_mobile/globals.dart';
import 'package:flutter/material.dart';

import 'package:da_kanji_recognizer_mobile/DaKanjiRecognizerDrawer.dart';
import 'package:showcaseview/showcaseview.dart';
import 'DrawingPainter.dart';
import 'PredictionButton.dart';

class DrawScreen extends StatefulWidget {
  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  DrawingPainter canvas;
  //the points which were drawn on the canvas
  List<List<Offset>> points = new List();
  // initialize predictions with blank
  List<String> predictions = List.generate(10, (index) => " ");
  // save the context for the Showcase view
  BuildContext myContext;

  @override
  void initState() {
    super.initState();

    // only show the showcase at an update/new install
    if(SETTINGS.showShowcaseViewDrawing){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(milliseconds: 200),
          () => ShowCaseWidget.of(myContext).startShowCase(SHOWCASE_KEYS_DRAWING));
      });
      SETTINGS.showShowcaseViewDrawing = false;
      SETTINGS.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = (Theme.of(context).brightness == Brightness.dark);
    canvas = new DrawingPainter(points, darkMode);

    return ShowCaseWidget(
      builder: Builder(
        builder: (context) { 
          myContext = context;
          return Scaffold(
          appBar: AppBar(
            title: Text("Drawing"),
          ),
          drawer: DaKanjiRecognizerDrawer(),
          body: Column(
            children: [
              // the canvas to draw on
              Container(
              width: MediaQuery.of(context).size.width * 5 / 6,
              height: MediaQuery.of(context).size.width * 5 / 6,
              margin: EdgeInsets.all(MediaQuery.of(context).size.width * 1 / 12),
              child: Showcase(
                key: SHOWCASE_KEYS_DRAWING[0],
                description: SHOWCASE_TEXTS_DRAWING[0],
                  child: GestureDetector(
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
                        points.add(new List());
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
              ),
              Spacer(),
              // undo/clear button
              Row(children: [
                // undo
                Showcase(
                  key: SHOWCASE_KEYS_DRAWING[1],
                  description: SHOWCASE_TEXTS_DRAWING[1],
                  child: IconButton(
                    icon: Icon(Icons.undo),
                    onPressed: () async {
                      //only run inference if canvas still has strokes
                      if(points.length > 0){
                        points.removeLast();
                        predictions = await canvas.runInference();
                      }
                      else
                        predictions = List.generate(10, (i) => " ");
                      setState(() {});
                    }
                  ),
                ),
                Spacer(),
                // clear
                Showcase(
                  key: SHOWCASE_KEYS_DRAWING[2],
                  description: SHOWCASE_TEXTS_DRAWING[2],
                  child: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        predictions = List.generate(10, (i) => " ");
                        points.clear();
                      });
                    }
                  ), 
                ),
              ]),
              // first row of prediction buttons
              Showcase(
                key: SHOWCASE_KEYS_DRAWING[3],
                description: SHOWCASE_TEXTS_DRAWING[3],
                child:
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 160, // set to 2*buttonHeight + 3*padding
                    child: GridView.count(
                      crossAxisCount: 5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      padding: EdgeInsets.all(5),
                      children: List.generate(10, (i) { 
                        if(i < 3){
                          return Showcase(
                            key: SHOWCASE_KEYS_DRAWING[4+i],
                            description: SHOWCASE_TEXTS_DRAWING[4+i],
                            child: PredictionButton(predictions[i])
                          );
                        }
                        else return PredictionButton(predictions[i]);
                      },
                      )
                    )
                  ),
              ),
              Spacer(),
            ],
          )
        );
      }),
    );
  }
}
