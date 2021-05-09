import 'package:da_kanji_mobile/provider/Changelog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:package_info/package_info.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'package:da_kanji_mobile/model/core/DarkTheme.dart';
import 'package:da_kanji_mobile/model/core/LightTheme.dart';
import 'package:da_kanji_mobile/model/core/DrawingInterpreter.dart';
import 'package:da_kanji_mobile/model/services/DeepLinks.dart';
import 'package:da_kanji_mobile/provider/KanjiBuffer.dart';
import 'package:da_kanji_mobile/provider/Settings.dart';
import 'package:da_kanji_mobile/provider/Lookup.dart';
import 'package:da_kanji_mobile/provider/About.dart';
import 'package:da_kanji_mobile/provider/Strokes.dart';
import 'package:da_kanji_mobile/view/HomeScreen.dart';
import 'package:da_kanji_mobile/view/Settingsscreen.dart';
import 'package:da_kanji_mobile/view/ChangelogScreen.dart';
import 'package:da_kanji_mobile/view/TestScreen.dart';
import 'package:da_kanji_mobile/view/drawing/DrawScreen.dart';
import 'package:da_kanji_mobile/view/AboutScreen.dart';
import 'globals.dart';


Future<void> main() async {

  // initialize the app
  WidgetsFlutterBinding.ensureInitialized();
  await init();

  runApp(
    Phoenix(
      child: DaKanjiApp(),
    )
  );

}


/// Initializes the app.
/// 
/// This function initializes:
/// * reads used version, CHANGELOG about from file
/// * loads the settings
/// * initializes tensorflow lite and reads the labels from file 
Future<void> init() async {
  // get the app's version 
  VERSION = (await PackageInfo.fromPlatform()).version;
  
  setupGetIt();

  await initDeepLinksStream();
  await getInitialDeepLink();
}


void setupGetIt() {
  GetIt.I.registerSingleton<Settings>(Settings());
  GetIt.I<Settings>().load();
  GetIt.I.registerSingleton<DrawingInterpreter>(DrawingInterpreter());
  GetIt.I.registerSingleton<Strokes>(Strokes());
  GetIt.I.registerSingleton<Lookup>(Lookup());
  GetIt.I.registerSingleton<KanjiBuffer>(KanjiBuffer());
  GetIt.I.registerSingleton<About>(About());
  GetIt.I<About>().init();
  GetIt.I.registerSingleton<Changelog>(Changelog());
  GetIt.I<Changelog>().init();
}

/// The starting widget of the app
class DaKanjiApp extends StatefulWidget {

  @override
  _DaKanjiAppState createState() => _DaKanjiAppState();

}

class _DaKanjiAppState extends State<DaKanjiApp> {

  @override
  dispose() {
    if (linkSub != null) linkSub.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // fix orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: APP_TITLE,

      // themes
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: GetIt.I<Settings>().selectedThemeMode(),

      //screens
      initialRoute: "/home", // "/testScreen",//
      routes: <String, WidgetBuilder>{
        "/home": (BuildContext context) => HomeScreen(),
        "/drawing": (BuildContext context) => DrawScreen(),
        "/settings": (BuildContext context) => SettingsScreen(),
        "/about": (BuildContext context) => AboutScreen(),
        "/changelog": (BuildContext context) => ChangelogScreen(),
        "/testScreen": (BuildContext context) => TestScreen(),
      },
    );
  }
}
