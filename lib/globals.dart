library my_prj.globals;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'Settings.dart';
import 'ShowcaseTuple.dart';


// the title of the app
const String APP_TITLE = "DaKanjiRecognizer";
// the version number of this app
// ignore: non_constant_identifier_names
String VERSION;
// all versions which implemented new features for the drawing screen
List<String> drawingScreenNewFeatures = ["1.0.0", "1.1.0"];

// the saved settings
// ignore: non_constant_identifier_names
final Settings SETTINGS = new Settings();

// the global key for the drawer
// ignore: non_constant_identifier_names
final GlobalKey<ScaffoldState> DRAWER_KEY = GlobalKey();

// showcase view keys
// ignore: non_constant_identifier_names
final List<ShowcaseTuple> SHOWCASE_DRAWING = [
  // 0 - Drawing canvas
  ShowcaseTuple(GlobalKey(), "Drawing",
    "Draw a character here", ContentAlign.bottom),
  // 1 - undo last stroke
  ShowcaseTuple(GlobalKey(), "Undo", 
    "Press to undo the last stroke", ContentAlign.bottom), 
  // 2 - clear canvas
  ShowcaseTuple(GlobalKey(), "Clear", 
    "Erase all strokes", ContentAlign.bottom), 
  // 3 - prediction buttons
  ShowcaseTuple(GlobalKey(), "Predictions", 
    "The predicted characters will be shown here", ContentAlign.top), 
  // 4 - short press prediction button
  ShowcaseTuple(GlobalKey(), "Short Press Prediction",
    "A short press copies the prediction", ContentAlign.bottom), 
  // 5 - long press prediction button
  ShowcaseTuple(GlobalKey(), "Long Press Prediction",
    "A long press opens the prediction in a dictionary", ContentAlign.bottom), 
  // 6 - multi search box
  ShowcaseTuple(GlobalKey(), "Multi search",
    "Here you can search multiple characters at once", ContentAlign.bottom), 
  // 7 - double tap prediction button
  ShowcaseTuple(GlobalKey(), "Double Tap Prediction",
    "A Double Tap adds the character to the search box", ContentAlign.bottom), 
  // 8 - multi search short press 
  ShowcaseTuple(GlobalKey(), "Multi search short press",
    "A short press copies the characters to the clipboard", ContentAlign.bottom), 
  // 9 - multi search long press
  ShowcaseTuple(GlobalKey(), "Multi search long press",
    "A long press opens the characters in a dictionary", ContentAlign.bottom), 
  // 10 - multi search double tap
  ShowcaseTuple(GlobalKey(), "Multi search double tap",
    "A double tap empties the field", ContentAlign.bottom), 
  // 11 - multi search swipe left
  ShowcaseTuple(GlobalKey(), "Multi search swipe left",
    "Swiping left on this field deletes the last character", ContentAlign.bottom), 
  // 12 - change dict in settings
  ShowcaseTuple(GlobalKey(), "Dictionary Settings",
    "In the settings the translation service can be chosen", ContentAlign.bottom), 
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