import 'dart:io' show Platform;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'DrawingPainter.dart';
import 'prediction_button.dart';

class Draw extends StatefulWidget {
  @override
  _DrawState createState() => _DrawState();
}

class _DrawState extends State<Draw> {
  List<List<Offset>> points = new List();
  bool openInJisho = false;
  bool darkModeOn = false;
  DrawingPainter canvas;
  List<String> predictions;

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;
    canvas = new DrawingPainter(points, darkModeOn);

    return Scaffold(
        body: Column(
      children: [
        Container(
            padding: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width * 1 / 12,
                MediaQuery.of(context).size.width * 1 / 12,
                MediaQuery.of(context).size.width * 1 / 12,
                0),
            child: Row(children: [
              Switch(
                  value: openInJisho,
                  onChanged: (value) {
                    setState(() {
                      openInJisho = value;
                    });
                  }),
              Text("open in Jisho"),
              Spacer()
            ])),
        Container(
          width: MediaQuery.of(context).size.width * 5 / 6,
          height: MediaQuery.of(context).size.width * 5 / 6,
          margin: EdgeInsets.fromLTRB(
            MediaQuery.of(context).size.width * 1 / 12,
            0,
            MediaQuery.of(context).size.width * 1 / 12,
            MediaQuery.of(context).size.width * 1 / 12,
          ),
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                RenderBox renderBox = context.findRenderObject();
                Offset point = renderBox.globalToLocal(details.localPosition);
                points[points.length - 1].add(point);
              });
            },
            onPanStart: (details) {
              setState(() {
                points.add(new List());
                RenderBox renderBox = context.findRenderObject();
                Offset point = renderBox.globalToLocal(details.localPosition);
                points[points.length - 1].add(point);
              });
            },
            onPanEnd: (details) {
              setState(() {
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
