import 'dart:io' show Platform;
import 'dart:ui';

import 'package:da_kanji_recognizer_mobile/DaKanjiRecognizerDrawer.dart';
import 'package:flutter/material.dart';

import 'DrawingPainter.dart';
import 'PredictionButton.dart';

class DrawScreen extends StatefulWidget {
  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  bool openInJisho = false;
  bool darkModeOn = false;
  DrawingPainter canvas;
  //the points which were drawn on the canvas
  List<List<Offset>> points = new List();
  // initialize predictions with blank
  List<String> predictions = List.generate(10, (index) => " ");

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;
    canvas = new DrawingPainter(points, darkModeOn);

    return Scaffold(
        appBar: AppBar(
          title: Text("Drawing"),
        ),
        drawer: DaKanjiRecognizerDrawer(),
        body: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 5 / 6,
              height: MediaQuery.of(context).size.width * 5 / 6,
              margin:
                  EdgeInsets.all(MediaQuery.of(context).size.width * 1 / 12),
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    RenderBox renderBox = context.findRenderObject();
                    Offset point =
                        renderBox.globalToLocal(details.localPosition);
                    points[points.length - 1].add(point);
                  });
                },
                onPanStart: (details) {
                  setState(() {
                    points.add(new List());
                    RenderBox renderBox = context.findRenderObject();
                    Offset point =
                        renderBox.globalToLocal(details.localPosition);
                    points[points.length - 1].add(point);
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    // remove single points and dont run inference
                    if (points[points.length - 1].length == 1)
                      points.removeLast();
                    else
                      predictions = canvas.runInference();
                  });
                },
                child: CustomPaint(
                  painter: canvas,
                ),
              ),
            ),
            Spacer(),
            // undo / clear buttons
            Row(children: [
              IconButton(
                  icon: Icon(Icons.undo),
                  onPressed: () {
                    setState(() {
                      points.removeLast();
                    });
                  }),
              Spacer(),
              IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      points.clear();
                    });
                  }),
            ]),
            // first prediction row
            Row(children: [
              PredictionButton(predictions[0]),
              PredictionButton(predictions[1]),
              PredictionButton(predictions[2]),
              PredictionButton(predictions[3]),
              PredictionButton(predictions[4]),
            ]),
            // second prediction row
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
