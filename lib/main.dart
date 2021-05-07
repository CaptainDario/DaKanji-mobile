import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

import 'package:package_info/package_info.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'package:da_kanji_mobile/provider/KanjiBuffer.dart';
import 'package:da_kanji_mobile/provider/Settings.dart';
import 'package:da_kanji_mobile/view/TestScreen.dart';
import 'package:da_kanji_mobile/provider/Lookup.dart';
import 'package:da_kanji_mobile/view/ChangelogScreen.dart';
import 'view/drawing/DrawScreen.dart';
import 'package:da_kanji_mobile/provider/Strokes.dart';
import 'package:da_kanji_mobile/model/core/DarkTheme.dart';
import 'package:da_kanji_mobile/model/core/LightTheme.dart';
import 'package:da_kanji_mobile/view/HomeScreen.dart';
import 'package:da_kanji_mobile/view/Settingsscreen.dart';
import 'view/AboutScreen.dart';
import 'globals.dart';
import 'model/core/DrawingInterpreter.dart';
import 'model/services/DeepLinks.dart';


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

  // load CHANGELOG and about from file
  final changelogs = await initChangelog();
  NEW_CHANGELOG = changelogs[0];
  WHOLE_CHANGELOG = changelogs[1];
  // about
  ABOUT = await initAbout();

  await initDeepLinksStream();
  await getInitialDeepLink();
}

/// Reads `CHANGELOG.md` from file and returns a converted version.
/// 
/// First reads the changelog from file and than returns a list with the changes 
/// in the current version and the whole changelog.
Future<List<String>> initChangelog () async {

  String changelog = await rootBundle.loadString("CHANGELOG.md");
  // whole changelog
  List<String> changelogList = changelog.split("\n");
  changelogList.removeRange(0, 3);
  String wholeChangelog = changelogList.join("\n");
  // newest changes
  final matches = new RegExp(r"(##.*?##)", dotAll: true);
  String newestChangelog = matches.firstMatch(changelog).group(0).toString();
  newestChangelog = newestChangelog.substring(0, newestChangelog.length - 2);

  return [newestChangelog, wholeChangelog];
}

/// Reads `about.md` from file and returns a converted version.
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

  String backend = "";

  if (Platform.isAndroid){
    // get platform information
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (androidInfo.isPhysicalDevice) {
      // use NNAPI on android if android API >= 27
      if (androidInfo.version.sdkInt >= 27) 
        backend = "Android NNAPI Delegate";
      // otherwise fallback to GPU delegate
      else 
        backend = "Android GPU Delegate";
    }
    // use CPU inference on emulators
    else{
      backend = "CPU";
    }
  }
  else if (Platform.isIOS){
    // get platform information
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

    if (iosInfo.isPhysicalDevice) 
      backend = "IOS Metal Delegate";
    // use CPU inference on emulators
    else 
      backend = "CPU";
  }
  
  about =
    about.replaceAll("USED_BACKEND", backend);
  about = about.replaceAll("VERSION", VERSION);

  return about;

}

void setupGetIt(){
  GetIt.I.registerSingleton<Settings>(Settings());
  GetIt.I<Settings>().load();
  GetIt.I.registerSingleton<DrawingInterpreter>(DrawingInterpreter());
  GetIt.I.registerSingleton<Strokes>(Strokes());
  GetIt.I.registerSingleton<Lookup>(Lookup());
  GetIt.I.registerSingleton<KanjiBuffer>(KanjiBuffer());
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
      //debugShowCheckedModeBanner: false,

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
