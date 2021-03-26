import 'package:da_kanji_recognizer_mobile/ChangelogScreen.dart';
import 'package:da_kanji_recognizer_mobile/DrawScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:package_info/package_info.dart';

import 'HomeScreen.dart';
import 'Settingsscreen.dart';
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

  // initialize the TFLite interpreter
  if (Platform.isAndroid) 
    CNN_KANJI_ONLY_INTERPRETER = await initInterpreterAndroid();
  else if (Platform.isIOS) 
    CNN_KANJI_ONLY_INTERPRETER = await initInterpreterIOS();
  else if (kIsWeb) 
    CNN_KANJI_ONLY_INTERPRETER = await initInterpreterWeb();
  
  // load labels, CHANGELOG and about from file
  String labels = 
    await rootBundle.loadString("assets/labels_CNN_kanji_only.txt");
  LABEL_LIST = labels.split("");
  final changelogs = await initChangelog();
  NEW_CHANGELOG = changelogs[0];
  WHOLE_CHANGELOG = changelogs[1];
  // about
  ABOUT = await initAbout();

  // run inference once at init -> no delay for first inference
  List<List<List<List<double>>>> _input = List<List<double>>.generate(
    64, (i) => List<double>.generate(64, (j) => 0.0)).
    reshape<double>([1, 64, 64, 1]);
  List<List<double>> _output =
      List<List<double>>.generate(1, (i) => 
        List<double>.generate(LABEL_LIST.length, (j) => 0.0));
  CNN_KANJI_ONLY_INTERPRETER.run(_input, _output);
}

Future<List<String>> initChangelog () async {

  String changelog = await rootBundle.loadString("assets/CHANGELOG.md");
  // whole changelog
  List<String> changelog_list = changelog.split("\n");
  changelog_list.removeRange(0, 3);
  String wholeChangelog = changelog_list.join("\n");
  // newest changes
  final matches = new RegExp(r"(##.*?##)", dotAll: true);
  //final matches = new RegExp(r"(##.*?Changes:)", dotAll: true);
  String newestChangelog = matches.firstMatch(changelog).group(0).toString();
  newestChangelog = newestChangelog.substring(0, newestChangelog.length - 2);

  return [newestChangelog, wholeChangelog];
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
      home: HomeScreen(),
      routes: <String, WidgetBuilder>{
        "/home": (BuildContext context) => HomeScreen(),
        "/drawing": (BuildContext context) => DrawScreen(),
        "/settings": (BuildContext context) => SettingsScreen(),
        "/about": (BuildContext context) => AboutScreen(),
        "/changelog": (BuildContext context) => ChangelogScreen()
      },
    );
  }
}
