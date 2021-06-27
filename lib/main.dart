import 'package:da_kanji_mobile/provider/PlatformDependentVariables.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'package:da_kanji_mobile/model/core/DarkTheme.dart';
import 'package:da_kanji_mobile/model/core/LightTheme.dart';
import 'package:da_kanji_mobile/model/core/DrawingInterpreter.dart';
import 'package:da_kanji_mobile/model/core/SettingsArguments.dart';
import 'package:da_kanji_mobile/model/services/DeepLinks.dart';
import 'package:da_kanji_mobile/provider/KanjiBuffer.dart';
import 'package:da_kanji_mobile/provider/Settings.dart';
import 'package:da_kanji_mobile/provider/Lookup.dart';
import 'package:da_kanji_mobile/provider/About.dart';
import 'package:da_kanji_mobile/provider/Strokes.dart';
import 'package:da_kanji_mobile/provider/Changelog.dart';
import 'package:da_kanji_mobile/provider/DrawerListener.dart';
import 'package:da_kanji_mobile/provider/UserData.dart';
import 'package:da_kanji_mobile/view/home/HomeScreen.dart';
import 'package:da_kanji_mobile/view/Settingsscreen.dart';
import 'package:da_kanji_mobile/view/ChangelogScreen.dart';
import 'package:da_kanji_mobile/view/TestScreen.dart';
import 'package:da_kanji_mobile/view/drawing/DrawScreen.dart';
import 'package:da_kanji_mobile/view/AboutScreen.dart';
import 'globals.dart';
import 'package:da_kanji_mobile/locales_json.dart';


Future<void> main() async {

  // initialize the app
  WidgetsFlutterBinding.ensureInitialized();
  await init();

  // wait for localization to be ready
  await EasyLocalization.ensureInitialized();

  runApp(
    Phoenix(
      child: EasyLocalization(
        supportedLocales: [Locale('en')],
        path: 'assets/translations',
        fallbackLocale: Locale('en'),
        assetLoader: CodegenLoader(),
        child: DaKanjiApp()
      ),
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
  BUILD_NR = (await PackageInfo.fromPlatform()).buildNumber;
  
  setupGetIt();

  await initDeepLinksStream();
  await getInitialDeepLink();
}


void setupGetIt() {
  // services to load from disk
  GetIt.I.registerSingleton<About>(About());
  GetIt.I.registerSingleton<Changelog>(Changelog());
  GetIt.I.registerSingleton<UserData>(UserData());
  GetIt.I.registerSingleton<Settings>(Settings());
  GetIt.I<Settings>().load();
  GetIt.I<Settings>().save();
  GetIt.I.registerSingleton<PlatformDependentVariables>(PlatformDependentVariables());

  // inference services
  GetIt.I.registerSingleton<DrawingInterpreter>(DrawingInterpreter());

  // draw screen services 
  GetIt.I.registerSingleton<KanjiBuffer>(KanjiBuffer());
  GetIt.I.registerSingleton<Strokes>(Strokes());
  
  // screen independent
  GetIt.I.registerSingleton(DrawerListener());
  GetIt.I.registerSingleton<Lookup>(Lookup());
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
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      onGenerateRoute: (settings) {
        PageRouteBuilder switchScreen (Widget screen) =>
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => screen,
            settings: settings,
            transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c)
          );

        // check type and extract arguments
        SettingsArguments args;
        if((settings.arguments is SettingsArguments))
          args = settings.arguments as SettingsArguments;
        else
          args = SettingsArguments(false);

        switch(settings.name){
          case "/home":
            return switchScreen(HomeScreen());
          case "/drawing":
            return switchScreen(DrawScreen(args.navigatedByDrawer));
          case "/settings":
            return switchScreen(SettingsScreen(args.navigatedByDrawer));
          case "/about":
            return switchScreen(AboutScreen(args.navigatedByDrawer));
          case "/changelog":
            return switchScreen(ChangelogScreen());
          case "/testScreen":
            return switchScreen(TestScreen());
        }
        throw UnsupportedError("Unknown route: ${settings.name}");
      },

      title: APP_TITLE,

      // themes
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: GetIt.I<Settings>().selectedThemeMode(),

      //screens
      home: HomeScreen(),
    );
  }
}
