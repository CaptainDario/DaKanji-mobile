import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class DrawingPainter extends CustomPainter {
  DrawingPainter({this.pointsList});
  List<List<Offset>> pointsList;
  List<Offset> offsetPoints = List();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    //set the background color of the canvas
    canvas.drawColor(Color.fromARGB(255, 0, 0, 255), BlendMode.srcATop);

    this.paintKanjiDrawingAid(canvas, size);

    Paint paint = Paint()
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // iterate over all strokes
    for (int s = 0; s < pointsList.length; s++) {
      // iterate over all points
      for (int p = 0; p < pointsList[s].length - 1; p++) {
        // draw the stroke
        canvas.drawLine(pointsList[s][p], pointsList[s][p + 1], paint);
      }
    }
  }

  void paintKanjiDrawingAid(Canvas canvas, Size size) {
    int dashAmount = 16;
    double dashLength = (size.width / (dashAmount + 1));

    // square
    Paint paint = Paint()
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // vertical
    paint.strokeWidth = 3.0;
    for (int i = 0; i < dashAmount + 1; i++) {
      if (i % 2 == 1) continue;
      canvas.drawLine(Offset(size.width / 2.0, dashLength * (i * 1.0)),
          Offset(size.width / 2.0, dashLength * (i + 1.0)), paint);
    }
    // horizontal
    for (int i = 0; i < dashAmount + 1; i++) {
      if (i % 2 == 1) continue;
      canvas.drawLine(Offset(dashLength * (i * 1.0), size.width / 2.0),
          Offset(dashLength * (i + 1.0), size.width / 2.0), paint);
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
