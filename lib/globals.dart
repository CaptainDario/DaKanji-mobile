library my_prj.globals;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'Settings.dart';


// the title of the app
const String APP_TITLE = "DaKanjiRecognizer";
// the version number of this app
// ignore: non_constant_identifier_names
String VERSION;

// the saved settings
// ignore: non_constant_identifier_names
final Settings SETTINGS = new Settings();

// the global key for the drawer
// ignore: non_constant_identifier_names
final GlobalKey<ScaffoldState> DRAWER_KEY = GlobalKey();

// showcase view keys
// ignore: non_constant_identifier_names
final List<GlobalKey> SHOWCASE_KEYS_DRAWING =
  List.generate(SHOWCASE_TEXTS_DRAWING.length, (i) => GlobalKey());
const List<String> SHOWCASE_IDENTIFIERS_DRAWING = [
  "Drawing",
  "Undo",
  "Clear",
  "Predictions",
  "Short Press",
  "Long Press",
  "Dictionary Settings"
];
const List<String> SHOWCASE_TEXTS_DRAWING = [
  "Draw a character here.",
  "Press to undo the last stroke.",
  "Erase all strokes",
  "The predicted characters will be shown here.",
  "A short press copies the prediction.",
  "A long press opens the prediction in a dictionary.",
  "In the settings the translation service can be chosen."
];
// ignore: non_constant_identifier_names
final List<ContentAlign> SHOWCASE_ALIGNS_DRAWING = [
  ContentAlign.bottom, ContentAlign.bottom, ContentAlign.bottom,
  ContentAlign.top, ContentAlign.bottom, ContentAlign.bottom,
  ContentAlign.bottom
];
// ignore: non_constant_identifier_names
final Color SHOWCASE_VIGNETTE_COLOR = Color.fromARGB(255, 10, 10, 10);

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

//about page
const GITHUB_DESKTOP_REPO = "https://github.com/CaptainDario/DaKanjiRecognizer-Desktop";
const GITHUB_MOBILE_REPO = "https://github.com/CaptainDario/DaKanjiRecognizer-Mobile";
const GITHUB_ML_REPO = "https://github.com/CaptainDario/DaKanjiRecognizer-ML";
const GITHUB_ISSUES = "https://github.com/CaptainDario/DaKanjiRecognizer-Mobile/issues/new";


const RATE_ON_MOBILE_STORE = "rating it on the AppStore/PlayStore";

const PLAYSTORE_BASE_URL = "https://play.google.com/store/apps/details?id=";
const PLAYSTORE_BASE_INTENT =  "market://details?id=";

const APPSTORE_PAGE = "";
const PLAYSTORE_PAGE = "https://play.google.com/store/apps/details?id=com.DaAppLab.DaKanjiRecognizer";

const DAAPPLAB_PLAYSTORE_PAGE = "https://play.google.com/store/apps/developer?id=DaAppLab";
const DAAPPLAB_APPSTORE_PAGE = "";

const TAKOBOTO_ID = "jp.takoboto";
const AKEBI_ID = "com.craxic.akebifree";
const AEDICT_ID = "sk.baka.aedict3";

const GOOGLE_TRANSLATE_ID = "com.google.android.apps.translate";

const PRIVACY_POLICE = "https://sites.google.com/view/dakanjirecognizerprivacypolicy";