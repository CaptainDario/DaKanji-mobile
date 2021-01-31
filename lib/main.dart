import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Settingsscreen.dart';
import 'DrawScreen.dart';
import 'AboutScreen.dart';
import 'globals.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // load the settings
  await SETTINGS.load();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  String title = "DaKanjiRecognizer";
  @override
  Widget build(BuildContext context) {
    // fix orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,

      // themes
      theme: ThemeData(brightness: Brightness.light,),
      darkTheme: ThemeData(brightness: Brightness.dark,),
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
