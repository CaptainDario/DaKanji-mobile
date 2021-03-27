library my_prj.globals;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'Styling.dart';
import 'Settings.dart';
import 'ShowcaseTuple.dart';


// the title of the app
const String APP_TITLE = "Da Kanji";

// the whole changelog of the app
String WHOLE_CHANGELOG = "";
// changelog of the newest version
String NEW_CHANGELOG = "";
// should the changelog be shown
bool SHOW_CHANGELOG = false;

// about page
String ABOUT = "";

// the version number of this app
// ignore: non_constant_identifier_names
String VERSION;
// all versions which implemented new features for the drawing screen
List<String> DRAWING_SCREEN_NEW_FEATURES = ["1.0.0", "1.1.0"];

// the saved settings
// ignore: non_constant_identifier_names
final Settings SETTINGS = new Settings();
final Styling CURRENT_STYLING = Styling();

// the global key for the drawer
// ignore: non_constant_identifier_names
final GlobalKey<ScaffoldState> DRAWER_KEY = GlobalKey();

// showcase view keys
// ignore: non_constant_identifier_names
List<ShowcaseTuple> SHOWCASE_DRAWING = [];
// ignore: non_constant_identifier_names
final Color SHOWCASE_VIGNETTE_COLOR = Color.fromARGB(255, 10, 10, 10);
bool SHOW_SHOWCASE_DRAWING = false;

// Assets
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