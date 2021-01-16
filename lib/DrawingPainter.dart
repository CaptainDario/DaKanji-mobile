import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'DrawingPoints.dart';

class DrawingPainter extends CustomPainter {
  DrawingPainter({this.pointsList});
  List<DrawingPoints> pointsList;
  List<Offset> offsetPoints = List();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    //set the background color of the canvas
    canvas.drawColor(Color.fromARGB(255, 0, 0, 255), BlendMode.srcATop);

    this.paintKanjiDrawingAid(canvas, size);

    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(pointsList[i].points, pointsList[i + 1].points,
            pointsList[i].paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i].points);
        offsetPoints.add(Offset(
            pointsList[i].points.dx + 0.1, pointsList[i].points.dy + 0.1));
        canvas.drawPoints(
            ui.PointMode.points, offsetPoints, pointsList[i].paint);
      }
    }
  }

  void paintKanjiDrawingAid(Canvas canvas, Size size) {
    int dash_amount = 20;
    int dashes = (size.width / (dash_amount + 1.0)).floor();

    // square
    Paint paint = Paint()
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    // vertical
    paint.strokeWidth = 3.0;
    for (int i = 0; i < dash_amount + 1; i++) {
      if (i % 2 == 1) continue;
      canvas.drawLine(Offset(size.width / 2.0, dashes * (i * 1.0)),
          Offset(size.width / 2.0, dashes * (i + 1.0)), paint);
    }
    // horizontal
    for (int i = 0; i < dash_amount + 1; i++) {
      if (i % 2 == 1) continue;
      canvas.drawLine(Offset(dashes * (i * 1.0), size.width / 2.0),
          Offset(dashes * (i + 1.0), size.width / 2.0), paint);
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
