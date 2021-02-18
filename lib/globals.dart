library my_prj.globals;

import 'package:flutter/cupertino.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'Settings.dart';

// the title of the app
const String APP_TITLE = "DaKanjiRecognizer";
// the version number of this app
const String VERSION = "0.3.0";

// the saved settings
// ignore: non_constant_identifier_names
final Settings SETTINGS = new Settings();

// showcase view keys
// ignore: non_constant_identifier_names
final List<GlobalKey> SHOWCASE_KEYS_DRAWING =
  List.generate(SHOWCASE_TEXTS_DRAWING.length, (i) => GlobalKey());
const List<String> SHOWCASE_TEXTS_DRAWING = [
  "Draw a character here.",
  "Press to undo the last stroke.",
  "Erase all strokes",
  "Here are the predicted characters.",
  "A short press copies the prediction.",
  "A long press opens the prediction in a dictionary.",
  "In the settings the dictionary can be chosen."
];

// Assets
const String LABELS_ASSET = 'assets/labels_CNN_kanji_only.txt';
const String CNN_KANJI_ONLY_ASSET = 'model_CNN_kanji_only.tflite';

// inference
// ignore: non_constant_identifier_names
List<String> LABEL_LIST;
// ignore: non_constant_identifier_names
Interpreter CNN_KANJI_ONLY_INTERPRETER;
// the backend used for inference CPU/GPU
// ignore: non_constant_identifier_names
String USED_BACKEND = "";
