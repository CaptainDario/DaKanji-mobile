import 'dart:math';

import 'package:flutter/material.dart';

class DrawingPainter extends CustomPainter {
  List<List<Offset>> pointsList;
  List<Offset> offsetPoints = List();
  bool darkMode = false;

  DrawingPainter(List<List<Offset>> pointsList, bool darkMode) {
    this.pointsList = pointsList;
    this.darkMode = darkMode;
  }

  List<String> runInference() {
    List<String> predictions = List();
    Random rnd = new Random();

    for (int i = 0; i < 10; i++) {
      predictions.add(rnd.nextInt(10).toString());
    }

    return predictions;
  }

  /// Creates an image of the current canvas.
  ///
  /// Creates a new ui.Canvas and repaints the current image on it.
  /// This canvas is than used to create an image.
  /// 
  /// @returns A list containing an image of the canvas.
  Future<Uint8List> getImageFromCanvas() async {
    // mark that the canvas is being recorded
    recording = true;

    // record the drawn character on a new canvas
    ui.PictureRecorder drawnImageRecorder = ui.PictureRecorder();
    Canvas getImageCanvas = new ui.Canvas(drawnImageRecorder);
    paint(getImageCanvas, size);
    ui.Picture pic = drawnImageRecorder.endRecording();
    recording = false;

    // convert the recording to an image
    final ui.Image img =
        await pic.toImage(size.width.floor(), size.height.floor());
    ByteData byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();

    return pngBytes;
  }

  void paintKanjiDrawingAid(Canvas canvas, Size size) {
    int dashAmount = 16;
    double dashLength = (size.width / (dashAmount + 1));

    Paint paint = Paint()
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;

    if (this.darkMode)
      paint.color = Colors.white;
    else
      paint.color = Colors.black;

    // the frame around the drawing canvas
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
  void paint(Canvas canvas, Size size) {
    // Setup canvas and paint
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    Paint paint = Paint()
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    if (this.darkMode)
      paint.color = Colors.white;
    else
      paint.color = Colors.black;

    // paint the strokes
    // iterate over all strokes
    for (int s = 0; s < pointsList.length; s++) {
      // iterate over all points
      for (int p = 0; p < pointsList[s].length - 1; p++) {
        // draw the stroke
        canvas.drawLine(pointsList[s][p], pointsList[s][p + 1], paint);
      }
    }

    // draw the rectangle and the dashed lines
    this.paintKanjiDrawingAid(canvas, size);
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
