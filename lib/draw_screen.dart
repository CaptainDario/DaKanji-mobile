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
                        // undo button
                        IconButton(
                            icon: Icon(Icons.undo),
                            onPressed: () {
                              setState(() {
                                points.removeLast();
                              });
                            }),

                        // clear button
                        IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
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
}
