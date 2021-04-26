import 'dart:ui' as ui;
import 'dart:typed_data';

import 'globals.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image;
import 'package:tflite_flutter/tflite_flutter.dart';


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

  /// input to the CNN
  List<List<List<List<double>>>> _input;

  /// output of the CNN
  List<List<double>> _output;

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
    // record the drawn character on a new canvas
    this.recording = true;
    ui.PictureRecorder drawnImageRecorder = ui.PictureRecorder();
    Canvas getImageCanvas = new ui.Canvas(drawnImageRecorder);
    paint(getImageCanvas, size);
    ui.Picture pic = drawnImageRecorder.endRecording();
    this.recording = false;

    // convert the recording to an image
    final ui.Image img =
        await pic.toImage(size.width.floor(), size.height.floor());
    
    ByteData byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();

    return pngBytes;
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
