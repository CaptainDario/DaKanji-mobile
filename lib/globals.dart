library my_prj.globals;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'model/core/ShowcaseTuple.dart';


// the title of the app
const String APP_TITLE = "DaKanji";

// deep link pattern
const String APP_LINK = r"dakanji://dakanji/";

// the whole changelog of the app
// ignore: non_constant_identifier_names
String WHOLE_CHANGELOG = "";
// changelog of the newest version
// ignore: non_constant_identifier_names
String NEW_CHANGELOG = "";
// should the changelog be shown
// ignore: non_constant_identifier_names
bool SHOW_CHANGELOG = false;

// about page
// ignore: non_constant_identifier_names
String ABOUT = "";

// the version number of this app
// ignore: non_constant_identifier_names
String VERSION;
// all versions which implemented new features for the drawing screen
// ignore: non_constant_identifier_names
List<String> DRAWING_SCREEN_NEW_FEATURES = ["1.0.0", "1.1.0"];

// the global key for the drawer
// ignore: non_constant_identifier_names
final GlobalKey<ScaffoldState> DRAWER_KEY = GlobalKey();

// showcase view keys
// ignore: non_constant_identifier_names
List<ShowcaseTuple> SHOWCASE_DRAWING = [];
// should the showcase of the draw screen be shown
// ignore: non_constant_identifier_names
bool SHOW_SHOWCASE_DRAWING = false;

//about page
const GITHUB_DESKTOP_REPO = "https://github.com/CaptainDario/DaKanji-Desktop";
const GITHUB_MOBILE_REPO = "https://github.com/CaptainDario/DaKanji-Mobile";
const GITHUB_ML_REPO = "https://github.com/CaptainDario/DaKanji-ML";
const GITHUB_ISSUES = "https://github.com/CaptainDario/DaKanji-Mobile/issues/new";


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