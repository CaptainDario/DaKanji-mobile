import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';


/// The canvas widget on which the user draws the kanji.
class DrawingPainter extends CustomPainter {
  /// the path which should be drawn on the canvas
  Path path = Path();

  /// if the app is running in dark mode
  bool darkMode;

  /// the size of the canvas
  Size size;

  /// if the canvas is currently being recorded
  bool recording;


  Uint8List snapImage;


  /// Constructs an DrawingPainter instance.
  /// 
  /// All points given with [pointsList] will be drawn on the canvas.
  /// [darkMode] should reflect in which mode the app is running.
  DrawingPainter(Path path, bool darkMode, Size size) {
    this.size = size;
    this.path = path;
    this.darkMode = darkMode;
    this.recording = false;
  }


  
  /// Returns an image of the current canvas as ui.Image.
  ///
  /// Creates a new ui.Canvas and repaints the current image on it. This canvas 
  /// than generates an image and returns it.
  Future<ui.Image> getImageFromCanvas() async {
    // record the drawn character on a new canvas
    this.recording = true;
    ui.PictureRecorder drawnImageRecorder = ui.PictureRecorder();
    Canvas getImageCanvas = new ui.Canvas(drawnImageRecorder);
    paint(getImageCanvas, size);
    ui.Picture pic = drawnImageRecorder.endRecording();
    this.recording = false;

    // convert the recording to an image
    return pic.toImage(size.width.floor(), size.height.floor());
  }

  /// Returns an image of the current canvas as Uint8List.
  ///
  /// Creates a new ui.Canvas and repaints the current image on it. This canvas 
  /// than generates an the drawn image and returns a Uint8List of it.
  Future<Uint8List> getPNGListFromCanvas() async {

    final ui.Image img = await getImageFromCanvas();
    
    ByteData byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();

    return pngBytes;
  }
  
  Future<Uint8List> getRGBAListFromCanvas() async {

    final ui.Image img = await getImageFromCanvas();
    
    ByteData byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    Uint8List rgbaBytes = byteData.buffer.asUint8List();

    return rgbaBytes;
  }

  /// Paints the [path] on the given [canvas].
  void drawPath(Canvas canvas) {
    // Setup canvas and paint
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    Paint paint = Paint()
      ..strokeWidth = size.width / 50.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (this.darkMode || this.recording)
      paint.color = Colors.white;
    else
      paint.color = Colors.black;

    // paint the strokes
    canvas.drawPath(this.path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) async {
    drawPath(canvas);
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
