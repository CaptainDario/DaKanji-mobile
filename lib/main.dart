import 'DrawScreen.dart';
import 'package:flutter/material.dart';

import 'package:da_kanji_recognizer_mobile/Settingsscreen.dart';
import 'AboutScreen.dart';
import 'Settings.dart';
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
    return MaterialApp(
      title: title,
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: DrawScreen(),
      routes: <String, WidgetBuilder>{
        "/settings": (BuildContext context) => SettingsScreen(),
        "/about": (BuildContext context) => AboutScreen()
      },
    );
  }
}
