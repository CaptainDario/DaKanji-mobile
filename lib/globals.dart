library my_prj.globals;

import 'package:tflite_flutter/tflite_flutter.dart';

import 'Settings.dart';

// the title of the app
String APP_TITLE = "DaKanjiRecognizer";

// the saved settings
Settings SETTINGS = new Settings();

// Assets
String LABELS_ASSET = 'assets/labels_CNN_kanji_only.txt';
String CNN_KANJI_ONLY_ASSET = 'model_CNN_kanji_only.tflite';

// inference
List<String> LABEL_LIST;
Interpreter CNN_KANJI_ONLY_INTERPRETER;
// the backend used for inference CPU/GPU
String USED_BACKEND = "";
