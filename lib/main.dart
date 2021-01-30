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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
