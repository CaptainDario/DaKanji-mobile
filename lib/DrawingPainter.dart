import 'dart:ui' as ui;
import 'dart:typed_data';

import 'globals.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image;
import 'package:tflite_flutter/tflite_flutter.dart';


/// The canvas widget on which the user draws the kanji.
class DrawingPainter extends CustomPainter {
  /// a list of points which were drawn on the canvas
  List<List<Offset>> pointsList;

  /// if the app is running in dark mode
  bool darkMode;

  /// the size of the canvas
  Size size;

  /// if the canvas is currently being recorded
  bool recording = false;

  /// input to the CNN
  List<List<List<List<double>>>> _input;

  /// output of the CNN
  List<List<double>> _output;

  /// Constructs an DrawingPainter instance.
  /// 
  /// All points given with [pointsList] will be drawn on the canvas.
  /// [darkMode] should reflect in which mode the app is running.
  DrawingPainter(List<List<Offset>> pointsList, bool darkMode) {
    this.pointsList = pointsList;
    this.darkMode = darkMode;
    this.recording = false;
    this._input = List<List<double>>.generate(
      64, (i) => List.generate(64, (j) => 0.0)).
      reshape<double>([1, 64, 64, 1]);
    this._output =
      List<List<double>>.generate(1, (i) => 
      List<double>.generate(LABEL_LIST.length, (j) => 0.0));
      
  }

  /// Create predictions based on the drawing by running inference on the CNN
  ///
  /// After running the inference the 10 most likely predictions are
  /// returned ordered by how likely they are [likeliest, ..., unlikeliest].
  Future<List<String>> runInference() async {
    List<String> predictions = List.generate(10, (i) => i.toString());

    // take image from canvas and resize it
    image.Image base = image.decodeImage(await getImageFromCanvas());
    image.Image resizedImage = image.copyResize(base,
      height: 64, width: 64, interpolation: image.Interpolation.cubic);
    Uint8List resizedBytes =
        resizedImage.getBytes(format: image.Format.luminance);

    // convert image for inference into shape [1, 64, 64, 1]
    for (int x = 0; x < 64; x++) {
      for (int y = 0; y < 64; y++) {
        double val = resizedBytes[(x * 64) + y].toDouble();
        if(val > 50){
          val = 255;
        }
        val = (val / 255).toDouble();
        _input[0][x][y][0] = val;
      }
    }

    // run inference
    CNN_KANJI_ONLY_INTERPRETER.run(_input, _output);

    // get the 10 most likely predictions
    for (int c = 0; c < 10; c++) {
      int index = 0;
      for (int i = 0; i < _output[0].length; i++) {
        if (_output[0][i] > _output[0][index]) index = i;
      }
      predictions[c] = LABEL_LIST[index];
      _output[0][index] = 0.0;
    }
    return predictions;
  }

  /// Creates an image of the current canvas.
  ///
  /// Creates a new ui.Canvas and repaints the current image on it. This canvas 
  /// than generates an image and returns it.
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

  /// Draws on the given [canvas] based on its [size] a drawing aid
  /// (vertical/horizontal dashed lines).
  void paintKanjiDrawingAid(Canvas canvas, Size size) {
    // setup the paint
    Paint paint = Paint()
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;
    // because the stroke color is black in lite mode
    // color must be set to black if an image is taken for inference
    if (this.darkMode)
      paint.color = Colors.white;
    else
      paint.color = Colors.black;

    // the frame around the drawing canvas
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // setup the amount of dashes to draw on the canvas
    int dashAmount = 16;
    double dashLength = (size.width / (dashAmount + 1));

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

  /// Paints the points of the [pointsList] on the given [canvas] with a size
  /// of [size].
  @override
  void paint(Canvas canvas, Size size) {
    // copy size
    this.size = size;
    // Setup canvas and paint
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    Paint paint = Paint()
      ..strokeWidth = size.width / 50.0
      ..strokeCap = StrokeCap.round;

    if (this.darkMode || this.recording)
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

    // if the canvas is NOT being recorded draw rectangle and dashed lines
    if (!recording) this.paintKanjiDrawingAid(canvas, size);
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
