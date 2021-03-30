import 'package:device_info/device_info.dart';

import 'package:tflite_flutter/tflite_flutter.dart';

import 'globals.dart';

/// Initializes the TFLite interpreter on android.
///
/// Uses NnAPI for devices with Android API >= 27. Otherwise uses the 
/// GPUDelegate. If it is detected that the apps runs on an emulator CPU mode 
/// is used
Future<Interpreter> initInterpreterAndroid() async {

  Interpreter interpreter;

  // get platform information
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

  // if the application is running not in an emulator
  if (androidInfo.isPhysicalDevice) {
    InterpreterOptions interpreterOptions;

    // use NNAPI on android if android API >= 27
    if (androidInfo.version.sdkInt >= 27) {
      USED_BACKEND = "Android NNAPI Delegate";
      interpreterOptions = InterpreterOptions()..useNnApiForAndroid = true;
    }
    // otherwise fallback to GPU delegate
    else {
      USED_BACKEND = "Android GPU Delegate";
      final gpuDelegateV2 = GpuDelegateV2(
          options: GpuDelegateOptionsV2(
              false,
              TfLiteGpuInferenceUsage.preferenceSustainSpeed,
              TfLiteGpuInferencePriority.minLatency,
              TfLiteGpuInferencePriority.auto,
              TfLiteGpuInferencePriority.auto));
      interpreterOptions = InterpreterOptions()..addDelegate(gpuDelegateV2);
    }

    // initialize interpreter(s)
    interpreter = await Interpreter.fromAsset(
        CNN_KANJI_ONLY_ASSET,
        options: interpreterOptions);
  }
  // use CPU inference on emulators
  else{
    interpreter = await initInterpreterFallback();
  }

  return interpreter;
}

/// Initializes the TFLite interpreter on iOS.
///
/// Uses the metal delegate if running on an actual device.
/// Otherwise uses CPU mode.
Future<Interpreter> initInterpreterIOS() async {

  Interpreter interpreter;

  // get platform information
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

  if (iosInfo.isPhysicalDevice) {
    final gpuDelegate = GpuDelegate(
      options: GpuDelegateOptions(true, TFLGpuDelegateWaitType.active),
    );
    var interpreterOptions = InterpreterOptions()..addDelegate(gpuDelegate);
    Interpreter interpreterIOS = await Interpreter.fromAsset(
        CNN_KANJI_ONLY_ASSET,
        options: interpreterOptions);

    USED_BACKEND = "IOS Metal Delegate";
    CNN_KANJI_ONLY_INTERPRETER = interpreterIOS;
  } 
  // use CPU inference on emulators
  else 
    interpreter = await initInterpreterFallback();
  
  return interpreter;

}


/// Initializes the interpreter with CPU mode set.
Future<Interpreter> initInterpreterFallback() async {
  USED_BACKEND = "CPU";
  
  return await Interpreter.fromAsset(CNN_KANJI_ONLY_ASSET);
}
