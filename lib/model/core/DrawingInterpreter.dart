import 'dart:io';
import 'dart:typed_data';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;

import 'package:tflite_flutter/tflite_flutter.dart';



/// The tf lite interpreter to recognize the hand drawn kanji characters.
/// 
/// Updates listeners when the predictions changed.
class DrawingInterpreter with ChangeNotifier{
  
  /// the tf lite interpreter to recognize kanjis
  Interpreter _interpreter;

  /// If the interpreter was initialized successfully
  bool _wasInitialized;

  /// The path to the interpreter asset
  String _assetPath;

  /// the backend used for inference CPU/GPU
  String usedBackend;

  /// The list of all labels the model can recognize.
  List<String> _labels;

  /// input to the CNN
  List<List<List<List<double>>>> _input;

  /// output of the CNN
  List<List<double>> _output;

  /// height of the input image
  int height;

  /// width of the input image
  int width;

  /// the prediciton the CNN made
  List<String> _predictions;

  /// The [_noPredictions] most likely predictions will used
  int _noPredictions;



  DrawingInterpreter()
  {
    _assetPath = "model_CNN_kanji_only.tflite"; 

    height = 64;
    width = 64;

    _noPredictions = 10;

    _setPredictions(List.generate(_noPredictions, (index) => " "));

    _wasInitialized = false;
  }

  /// Initialize the interpreter
  /// 
  /// Caution: This method needs to be called before using the interpreter.
  void init() async {

    if (Platform.isAndroid) 
      _interpreter = await initInterpreterAndroid();
    else if (Platform.isIOS) 
      _interpreter = await initInterpreterIOS();
    else
      throw PlatformException(code: "Platform not supported.");
  
    var l = await rootBundle.loadString("assets/labels_CNN_kanji_only.txt");
    _labels = l.split("");
    
    _wasInitialized = true;
  
    // allocate memory for inference
    _input = List<List<double>>.generate(
      64, (i) => List.generate(64, (j) => 0.0)).
      reshape<double>([1, 64, 64, 1]);
    this._output =
      List<List<double>>.generate(1, (i) => 
      List<double>.generate(_labels.length, (j) => 0.0));
  }


  List<String> get predictions{
    return _predictions;
  }

  void _setPredictions(List<String> predictions){
    _predictions = predictions;
  }


  /// Call this to free the memory of this interpreter
  /// 
  /// Should be invoked when a different screen is opened which uses a 
  /// different interpreter.
  void free() {
    _output = null;
    _input = null;
    _interpreter = null;
    clearPredictions();
    _wasInitialized = false;
  }

  void clearPredictions(){
    _setPredictions(List.generate(_noPredictions, (index) => " "));
  }

  Interpreter get interpreter{

    return _interpreter;
  }

  /// Create predictions based on the drawing by running inference on the CNN
  ///
  /// After running the inference the 10 most likely predictions are
  /// returned ordered by how likely they are [likeliest, ..., unlikeliest].
  void runInference(Uint8List inputImage) async {
    
    if(!_wasInitialized)
      throw Exception(
        "You are trying to use the interpreter before it was initialized!\n" +
        "Execute init() first!"
      );

    // take image from canvas and resize it
    image.Image base = image.decodeImage(inputImage);
    image.Image resizedImage = image.copyResize(base,
      height: 64, width: 64, interpolation: image.Interpolation.cubic);
    Uint8List resizedBytes =
        resizedImage.getBytes(format: image.Format.luminance);

    // convert image for inference into shape [1, 64, 64, 1]
    for (int x = 0; x < 64; x++) {
      for (int y = 0; y < 64; y++) {
        double val = resizedBytes[(x * 64) + y].toDouble();
        if(val > 50){
          val = 255;
        }
        val = (val / 255).toDouble();
        _input[0][x][y][0] = val;
      }
    }

    // run inference
    _interpreter.run(_input, _output);

    // get the 10 most likely predictions
    for (int c = 0; c < 10; c++) {
      int index = 0;
      for (int i = 0; i < _output[0].length; i++) {
        if (_output[0][i] > _output[0][index]) index = i;
      }
      predictions[c] = _labels[index];
      _output[0][index] = 0.0;
    }
  }

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
        usedBackend = "Android NNAPI Delegate";
        interpreterOptions = InterpreterOptions()..useNnApiForAndroid = true;
      }
      // otherwise fallback to GPU delegate
      else {
        usedBackend = "Android GPU Delegate";
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
          _assetPath,
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
          _assetPath,
          options: interpreterOptions);

      usedBackend = "IOS Metal Delegate";
      interpreter = interpreterIOS;
    } 
    // use CPU inference on emulators
    else 
      interpreter = await initInterpreterFallback();
    
    return interpreter;

  }


  /// Initializes the interpreter with CPU mode set.
  Future<Interpreter> initInterpreterFallback() async {
    usedBackend = "CPU";
    
    return await Interpreter.fromAsset(_assetPath);
  }
}