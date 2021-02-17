import 'package:flutter/material.dart';

import 'package:da_kanji_recognizer_mobile/DaKanjiRecognizerDrawer.dart';
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

  @override
  Widget build(BuildContext context) {
    bool darkMode = (Theme.of(context).brightness == Brightness.dark);
    canvas = new DrawingPainter(points, darkMode);

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
              margin:
                  EdgeInsets.all(MediaQuery.of(context).size.width * 1 / 12),
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
            Spacer(),
            // undo/clear button
            Row(children: [
              // undo
              IconButton(
                  icon: Icon(Icons.undo),
                  onPressed: () async {
                    points.removeLast();
                    //only run inference if canvas still has strokes
                    if(points.length > 0)
                      predictions = await canvas.runInference();
                    else
                      predictions = List.generate(10, (i) => " ");
                    setState(() {});
                  }),
              Spacer(),
              // clear
              IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      predictions = List.generate(10, (i) => " ");
                      points.clear();
                    });
                  }),
            ]),
            // first row of preiction buttons
            Row(children: [
              PredictionButton(predictions[0]),
              PredictionButton(predictions[1]),
              PredictionButton(predictions[2]),
              PredictionButton(predictions[3]),
              PredictionButton(predictions[4]),
            ]),
            // second row of prediction buttons
            Row(children: [
              PredictionButton(predictions[5]),
              PredictionButton(predictions[6]),
              PredictionButton(predictions[7]),
              PredictionButton(predictions[8]),
              PredictionButton(predictions[9]),
            ]),
            Spacer(),
          ],
        ));
  }
}
