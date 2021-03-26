import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:package_info/package_info.dart';

import 'Settingsscreen.dart';
import 'DrawScreen.dart';
import 'AboutScreen.dart';
import 'globals.dart';
import 'initInterpreter.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await init();

  runApp(
    Phoenix(
      child: DaKanjiRecognizerApp(),
    )
  );

}

Future<void> init() async {
  // get the app's version 
  VERSION = (await PackageInfo.fromPlatform()).version;
  
  // load the settings
  SETTINGS.load();

  // load labels from text file and one hot encode them
  String labels = await rootBundle.loadString(LABELS_ASSET);
  LABEL_LIST = labels.split("");

  // initialize the TFLite interpreter
  if (Platform.isAndroid) 
    CNN_KANJI_ONLY_INTERPRETER = await initInterpreterAndroid();
  else if (Platform.isIOS) 
    CNN_KANJI_ONLY_INTERPRETER = await initInterpreterIOS();
  else if (kIsWeb) 
    CNN_KANJI_ONLY_INTERPRETER = await initInterpreterWeb();

  // run inference once at init -> no delay for first inference
  List<List<List<List<double>>>> _input = List<List<double>>.generate(
    64, (i) => List<double>.generate(64, (j) => 0.0)).
    reshape<double>([1, 64, 64, 1]);
  List<List<double>> _output =
      List<List<double>>.generate(1, (i) => 
        List<double>.generate(LABEL_LIST.length, (j) => 0.0));
  CNN_KANJI_ONLY_INTERPRETER.run(_input, _output);
}


Future<String> initAbout () async {

  String about = await rootBundle.loadString("assets/about.md");

  about = about.replaceAll("GITHUB_DESKTOP_REPO", GITHUB_DESKTOP_REPO);
  about = about.replaceAll("GITHUB_MOBILE_REPO", GITHUB_MOBILE_REPO);
  about = about.replaceAll("GITHUB_ML_REPO", GITHUB_ML_REPO);
  about = about.replaceAll("GITHUB_ISSUES", GITHUB_ISSUES);
  about = about.replaceAll("PRIVACY_POLICE", PRIVACY_POLICE);

  if(Platform.isAndroid){
    about = about.replaceAll("RATE_ON_MOBILE_STORE", PLAYSTORE_PAGE);
    about = about.replaceAll("DAAPPLAB_STORE_PAGE", DAAPPLAB_PLAYSTORE_PAGE);
  }
  else if(Platform.isIOS){
    about = about.replaceAll("RATE_ON_MOBILE_STORE", APPSTORE_PAGE);
    about = about.replaceAll("DAAPPLAB_STORE_PAGE", DAAPPLAB_APPSTORE_PAGE);
  }
  
  about = about.replaceAll("USED_BACKEND", USED_BACKEND);
  about = about.replaceAll("VERSION", VERSION);

  return about;

}


class DaKanjiRecognizerApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    // fix orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: APP_TITLE,
      //debugShowCheckedModeBanner: false,

      // themes
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: SETTINGS.themesDict[SETTINGS.selectedTheme],

      //screens
      home: DrawScreen(),
      routes: <String, WidgetBuilder>{
        "/settings": (BuildContext context) => SettingsScreen(),
        "/about": (BuildContext context) => AboutScreen()
      },
    );
  }
}
