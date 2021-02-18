import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'Settingsscreen.dart';
import 'DrawScreen.dart';
import 'AboutScreen.dart';
import 'globals.dart';
import 'initInterpreter.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await init();

  runApp(DaKanjiRecognizerApp());

}

Future<void> init() async {
  // load the settings
  SETTINGS.load();

  // load labels from text file and one hot encode them
  String labels = await rootBundle.loadString(LABELS_ASSET);
  LABEL_LIST = labels.split("");

  // initialize the TFLite interpreter
  if (Platform.isAndroid) 
    initInterpreterAndroid();
  else if (Platform.isIOS) 
    initInterpreterIOS();
  else if (kIsWeb) 
    initInterpreterWeb();
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
      debugShowCheckedModeBanner: false,

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
