import 'dart:io' show Platform;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'DrawingPainter.dart';

class Draw extends StatefulWidget {
  @override
  _DrawState createState() => _DrawState();
}

class _DrawState extends State<Draw> {
  List<List<Offset>> points = new List();
  bool darkModeOn = false;

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;
    return Scaffold(
        body: Column(
      children: [
          Container(
            width: MediaQuery.of(context).size.width * 5 / 6,
            height: MediaQuery.of(context).size.width * 5 / 6,
            margin: EdgeInsets.all(MediaQuery.of(context).size.width * 1 / 12),
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
                  // add inference here
                });
              },
              child: CustomPaint(
              painter: new DrawingPainter(points, darkModeOn),
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
          /*
        Switch(
          value: openInJisho,
          onChanged: (value) {
            setState(() {
              openInJisho = value;
            });
          },
        ),*/
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
          Expanded(
              child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(0),
                      child: RaisedButton(
                          color: Colors.white.withAlpha(50),
                          padding: EdgeInsets.all(0),
                          onPressed: () {},
                          child: FittedBox(
                              child: Text(
                            "漢",
                            textAlign: TextAlign.center,
                            style: new TextStyle(fontSize: 1000.0),
                          )))))),
          Expanded(
              child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(0),
                      child: RaisedButton(
                          color: Colors.white.withAlpha(50),
                          padding: EdgeInsets.all(0),
                          onPressed: () {},
                          child: FittedBox(
                              child: Text(
                            "漢",
                            textAlign: TextAlign.center,
                            style: new TextStyle(fontSize: 1000.0),
                          )))))),
          Expanded(
              child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(0),
                      child: RaisedButton(
                          color: Colors.white.withAlpha(50),
                          padding: EdgeInsets.all(0),
                          onPressed: () {},
                          child: FittedBox(
                              child: Text(
                            "漢",
                            textAlign: TextAlign.center,
                            style: new TextStyle(fontSize: 1000.0),
                          )))))),
          Expanded(
              child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(0),
                      child: RaisedButton(
                          color: Colors.white.withAlpha(50),
                          padding: EdgeInsets.all(0),
                          onPressed: () {},
                          child: FittedBox(
                              child: Text(
                            "漢",
                            textAlign: TextAlign.center,
                            style: new TextStyle(fontSize: 1000.0),
                          )))))),
          Expanded(
              child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(0),
                      child: RaisedButton(
                          color: Colors.white.withAlpha(50),
                          padding: EdgeInsets.all(0),
                          onPressed: () {},
                          child: FittedBox(
                              child: Text(
                            "漢",
                            textAlign: TextAlign.center,
                            style: new TextStyle(fontSize: 1000.0),
                          )))))),
          ]),
        // second prediction row
          Row(children: [
          Expanded(
              child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(0),
                      child: RaisedButton(
                          color: Colors.white.withAlpha(50),
                          padding: EdgeInsets.all(0),
                          onPressed: () {},
                          child: FittedBox(
                              child: Text(
                            "漢",
                            textAlign: TextAlign.center,
                            style: new TextStyle(fontSize: 1000.0),
                          )))))),
          Expanded(
              child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(0),
                      child: RaisedButton(
                          color: Colors.white.withAlpha(50),
                          padding: EdgeInsets.all(0),
                          onPressed: () {},
                          child: FittedBox(
                              child: Text(
                            "漢",
                            textAlign: TextAlign.center,
                            style: new TextStyle(fontSize: 1000.0),
                          )))))),
          Expanded(
              child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(0),
                      child: RaisedButton(
                          color: Colors.white.withAlpha(50),
                          padding: EdgeInsets.all(0),
                          onPressed: () {},
                          child: FittedBox(
                              child: Text(
                            "漢",
                            textAlign: TextAlign.center,
                            style: new TextStyle(fontSize: 1000.0),
                          )))))),
          Expanded(
              child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(0),
                      child: RaisedButton(
                          color: Colors.white.withAlpha(50),
                          padding: EdgeInsets.all(0),
                          onPressed: () {},
                          child: FittedBox(
                              child: Text(
                            "漢",
                            textAlign: TextAlign.center,
                            style: new TextStyle(fontSize: 1000.0),
                          )))))),
          Expanded(
              child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(0),
                      child: RaisedButton(
                          color: Colors.white.withAlpha(50),
                          padding: EdgeInsets.all(0),
                          onPressed: () {},
                          child: FittedBox(
                              child: Text(
                            "漢",
                            textAlign: TextAlign.center,
                            style: new TextStyle(fontSize: 1000.0),
                          )))))),
          ]),
        Spacer(),
      ],
    ));
  }
}
