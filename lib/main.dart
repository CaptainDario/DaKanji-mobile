import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:device_info/device_info.dart';

import 'Settingsscreen.dart';
import 'DrawScreen.dart';
import 'AboutScreen.dart';
import 'globals.dart';

import 'package:tflite_flutter/tflite_flutter.dart';

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

  initInterpreter();
}

void initInterpreter() async {
  // get platform information
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    // if the application is running not in an emulator
    if (androidInfo.isPhysicalDevice) {
      InterpreterOptions interpreterOptions;

      // use NNAPI on android if android API >= 27
      if (androidInfo.version.sdkInt >= 27) {
      usedBackend = "Android NNAPI Delegate";
        interpreterOptions = InterpreterOptions()..useNnApiForAndroid = true;
      }
      // otherwise fallback to GPU delegate
      else {
      usedBackend = "Android GPU Delegate";
        final gpuDelegateV2 = GpuDelegateV2(
            options: GpuDelegateOptionsV2(
                false,
                TfLiteGpuInferenceUsage.fastSingleAnswer,
                TfLiteGpuInferencePriority.minLatency,
                TfLiteGpuInferencePriority.auto,
                TfLiteGpuInferencePriority.auto));
        interpreterOptions = InterpreterOptions()..addDelegate(gpuDelegateV2);
      }

      // initialize interpreter(s)
      CNN_KANJI_ONLY_INTERPRETER = await Interpreter.fromAsset(
          CNN_KANJI_ONLY_ASSET,
          options: interpreterOptions);
    }
  }
  else if (Platform.isIOS) {
    usedBackend = "IOS Metal Delegate";
    final gpuDelegate = GpuDelegate(
      options: GpuDelegateOptions(true, TFLGpuDelegateWaitType.active),
    );
    var interpreterOptions = InterpreterOptions()..addDelegate(gpuDelegate);
    CNN_KANJI_ONLY_INTERPRETER = await Interpreter.fromAsset(
        CNN_KANJI_ONLY_ASSET,
        options: interpreterOptions);
  }
  // use cpu inference on emulators
  else {
    usedBackend = "CPU";
    CNN_KANJI_ONLY_INTERPRETER =
        await Interpreter.fromAsset(CNN_KANJI_ONLY_ASSET);
  }
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
      title: appTitle,
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
