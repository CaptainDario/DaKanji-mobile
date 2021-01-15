import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

class Draw extends StatefulWidget {
  @override
  _DrawState createState() => _DrawState();
}

class _DrawState extends State<Draw> {
  Color selectedColor = Colors.black;
  Color pickerColor = Colors.black;
  double strokeWidth = 3.0;
  List<DrawingPoints> points = List();
  bool showBottomList = false;
  double opacity = 1.0;
  StrokeCap strokeCap = (Platform.isAndroid) ? StrokeCap.butt : StrokeCap.round;
  SelectedMode selectedMode = SelectedMode.StrokeWidth;
  List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.amber,
    Colors.black
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                color: Colors.greenAccent),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                          icon: Icon(Icons.undo),
                          onPressed: () {
                            setState(() {
                              showBottomList = false;
                              points.clear();
                            });
                          }),
                      IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              showBottomList = false;
                              points.clear();
                            });
                          }),
                    ],
                  ),
                ],
              ),
            )),
      ),
        body: Column(children: [
          Container(
            width: MediaQuery.of(context).size.width * 3 / 4,
            height: MediaQuery.of(context).size.width * 3 / 4,
            margin: EdgeInsets.all(MediaQuery.of(context).size.width * 1 / 8),
            child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject();
            points.add(DrawingPoints(
                points: renderBox.globalToLocal(details.globalPosition),
                paint: Paint()
                  ..strokeCap = strokeCap
                  ..isAntiAlias = true
                  ..color = selectedColor.withOpacity(opacity)
                  ..strokeWidth = strokeWidth));
          });
        },
        onPanStart: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject();
            points.add(DrawingPoints(
                points: renderBox.globalToLocal(details.globalPosition),
                paint: Paint()
                  ..strokeCap = strokeCap
                  ..isAntiAlias = true
                  ..color = selectedColor.withOpacity(opacity)
                  ..strokeWidth = strokeWidth));
          });
        },
        onPanEnd: (details) {
          setState(() {
            points.add(null);
          });
        },
        child: CustomPaint(
          size: Size.infinite,
          painter: DrawingPainter(
            pointsList: points,
          ),
        ),
      ),
          ),
          Row(children: [
            Expanded(child: FlatButton(onPressed: () {}, child: Text("漢字 1"))),
            Expanded(child: FlatButton(onPressed: () {}, child: Text("漢字 2"))),
            Expanded(child: FlatButton(onPressed: () {}, child: Text("漢字 3"))),
            Expanded(child: FlatButton(onPressed: () {}, child: Text("漢字 4"))),
            Expanded(child: FlatButton(onPressed: () {}, child: Text("漢字 5")))
          ]),
          Row(children: [
            Expanded(child: FlatButton(onPressed: () {}, child: Text("漢字 6"))),
            Expanded(child: FlatButton(onPressed: () {}, child: Text("漢字 7"))),
            Expanded(child: FlatButton(onPressed: () {}, child: Text("漢字 8"))),
            Expanded(child: FlatButton(onPressed: () {}, child: Text("漢字 9"))),
            Expanded(child: FlatButton(onPressed: () {}, child: Text("漢字 10")))
          ]),
        ]));
}

class DrawingPoints {
  Paint paint;
  Offset points;
  DrawingPoints({this.points, this.paint});
}

enum SelectedMode { StrokeWidth, Opacity, Color }
