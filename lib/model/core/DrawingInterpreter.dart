import 'dart:io';
import 'dart:typed_data';

import 'package:da_kanji_mobile/model/core/DrawingIsolateUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:device_info/device_info.dart';
import 'package:image/image.dart' as image;

import 'package:tflite_flutter/tflite_flutter.dart';



/// The tf lite interpreter to recognize the hand drawn kanji characters.
/// 
/// Notifies listeners when the predictions changed.
class DrawingInterpreter with ChangeNotifier{
  


  /// the tf lite interpreter to recognize kanjis
  Interpreter _interpreter;

  DrawingIsolateUtils _isolateUtils;

  /// If the interpreter was initialized successfully
  bool wasInitialized;

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

  /// the prediction the CNN made
  List<String> _predictions;

  /// The [_noPredictions] most likely predictions will used
  int _noPredictions;



  List<String> get predictions{
    return _predictions;
  }

  void _setPredictions(List<String> predictions){
    _predictions = predictions;
  }

  get labels {
    return _labels;
  }

  get isolateUtils{
    return _isolateUtils;
  }

  get interpreteraddress{
    return _interpreter.address;
  }


  DrawingInterpreter() {
    _assetPath = "model_CNN_kanji_only.tflite"; 

    height = 64;
    width = 64;

    _noPredictions = 10;

    _setPredictions(List.generate(_noPredictions, (index) => " "));

    
    wasInitialized = false;
  }

  /// Initialize the interpreter in the main isolate (invoking it can lead to 
  /// UI jank)
  /// 
  /// Caution: This method needs to be called before using the interpreter.
  void init() async {

    if(wasInitialized){
      print("Drawing interpreter already initialized."
      "Skipping init and returning existing interpreter.");
      return;
    }
    if (Platform.isAndroid)
      _interpreter = await _initInterpreterAndroid();
    else if (Platform.isIOS) 
      _interpreter = await _initInterpreterIOS();
    else
      throw PlatformException(code: "Platform not supported.");

    print(usedBackend);

    var l = await rootBundle.loadString("assets/labels_CNN_kanji_only.txt");
    _labels = l.split("");
    
    // allocate memory for inference in / output
    _input = List<List<double>>.generate(
      64, (i) => List.generate(64, (j) => 0.0)).
      reshape<double>([1, 64, 64, 1]);
    this._output =
      List<List<double>>.generate(1, (i) => 
      List<double>.generate(_labels.length, (j) => 0.0));

    _isolateUtils = DrawingIsolateUtils();
    _isolateUtils.start();

    wasInitialized = true;
  }

  /// Initialize the isolate in which the inference should be run.
  void initIsolate(Interpreter interpreter, List<String> labels) async {

    _interpreter = interpreter;
    _labels = labels;

    // allocate memory for inference in / output
    _input = List<List<double>>.generate(
      64, (i) => List.generate(64, (j) => 0.0)).
      reshape<double>([1, 64, 64, 1]);
    this._output =
      List<List<double>>.generate(1, (i) => 
      List<double>.generate(_labels.length, (j) => 0.0));

    wasInitialized = true;
  }

  /// Call this to free the memory of this interpreter
  /// 
  /// Should be invoked when a different screen is opened which uses a 
  /// different interpreter.
  void free() {
    _interpreter.close();
    _output = null;
    _input = null;
    _interpreter = null;
    clearPredictions();
    wasInitialized = false;
  }

  /// Clear all predictions by setting them to " "
  void clearPredictions(){
    _setPredictions(List.generate(_noPredictions, (index) => " "));
    notifyListeners();
  }

  /// Create predictions based on the drawing by running inference on the CNN
  ///
  /// After running the inference the 10 most likely predictions are
  /// returned ordered by how likely they are [likeliest, ..., unlikeliest].
  void runInference(Uint8List inputImage, {bool runInIsolate = true}) async {
    
    if(!wasInitialized)
      throw Exception(
        "You are trying to use the interpreter before it was initialized!\n" +
        "Execute init() first!"
      );

    if(runInIsolate){
      _predictions = await _isolateUtils.runInference(
        inputImage,
        _interpreter.address,
        labels
      );
    }
    else{
      // take image from canvas and resize it
      image.Image base = image.decodeImage(inputImage);
      image.Image resizedImage = image.copyResize(base,
        height: 64, width: 64, interpolation: image.Interpolation.cubic);
      Uint8List resizedBytes =
          resizedImage.getBytes(format: image.Format.luminance);

      // convert image for inference into shape [1, 64, 64, 1]
      // also apply thresholding and normalization [0, 1]
      for (int x = 0; x < 64; x++) {
        for (int y = 0; y < 64; y++) {
          double val = resizedBytes[(x * 64) + y].toDouble();
          
          // apply thresholding and normalize image
          val = val > 50 ? 1.0 : 0.0;
          
          _input[0][x][y][0] = val;
        }
      }
      // run inference
      _interpreter.run(_input, _output);

      // get the 10 most likely predictions
      for (int c = 0; c < _noPredictions; c++) {
        int index = 0;
        for (int i = 0; i < _output[0].length; i++) {
          if (_output[0][i] > _output[0][index]) index = i;
        }
        predictions[c] = _labels[index];
        _output[0][index] = 0.0;
      }
    }
    
    notifyListeners();
  }

  /// Initializes the TFLite interpreter on android.
  ///
  /// Uses NnAPI for devices with Android API >= 27. Otherwise uses the 
  /// GPUDelegate. If it is detected that the apps runs on an emulator CPU mode 
  /// is used
  Future<Interpreter> _initInterpreterAndroid() async {

    Interpreter interpreter;

    // get platform information
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    try{
      if(androidInfo.isPhysicalDevice){
        // use NNAPI on android if android API >= 27
        if (androidInfo.version.sdkInt >= 27) {
          interpreter = await _nnapiInterpreter();
        }
        // otherwise fallback to GPU delegate
        else {
          usedBackend = "Android GPU Delegate";
          interpreter = await _gpuInterpreterAndroid();
        }
      }
      // use CPU inference on emulators
      else 
        interpreter = await _cpuInterpreter();
    }
    // use CPU inference on exceptions
    catch (e){
      interpreter = await _cpuInterpreter();
    }

    return interpreter;
  }
  
  /// Initializes the TFLite interpreter on iOS.
  ///
  /// Uses the metal delegate if running on an actual device.
  /// Otherwise uses CPU mode.
  Future<Interpreter> _initInterpreterIOS() async {

    Interpreter interpreter;

    // get platform information
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

    if (iosInfo.isPhysicalDevice) {
      usedBackend = "IOS Metal Delegate";
      interpreter = await _gpuInterpreterIOS();
    } 
    // use CPU inference on emulators
    else 
      interpreter = await _cpuInterpreter();
    
    return interpreter;

  }

  /// Initializes the interpreter with NPU acceleration for Android.
  Future<Interpreter> _nnapiInterpreter() async {
    final options = InterpreterOptions()..useNnApiForAndroid = true;
    Interpreter i = await Interpreter.fromAsset(_assetPath, options: options);
    usedBackend = "Android NNAPI Delegate";
    return i; 
  }

  /// Initializes the interpreter with GPU acceleration for Android.
  Future<Interpreter> _gpuInterpreterAndroid() async {
    final gpuDelegateV2 = GpuDelegateV2(
      options: GpuDelegateOptionsV2(
        false,
        TfLiteGpuInferenceUsage.fastSingleAnswer,
        TfLiteGpuInferencePriority.minLatency,
        TfLiteGpuInferencePriority.auto,
        TfLiteGpuInferencePriority.auto
      )
    );
    final options = InterpreterOptions()..addDelegate(gpuDelegateV2);
    Interpreter i = await Interpreter.fromAsset(_assetPath, options: options);

    return i;
  }

  /// Initializes the interpreter with GPU acceleration for iOS.
  Future<Interpreter> _gpuInterpreterIOS() async {

    final gpuDelegate = GpuDelegate(
      options: GpuDelegateOptions(true, TFLGpuDelegateWaitType.active),
    );
    var interpreterOptions = InterpreterOptions()..addDelegate(gpuDelegate);
    return await Interpreter.fromAsset(_assetPath, options: interpreterOptions);
  }

  /// Initializes the interpreter with CPU mode set.
  Future<Interpreter> _cpuInterpreter() async {
    usedBackend = "CPU";
    final options = InterpreterOptions()
      ..threads = Platform.numberOfProcessors - 1;
    return await Interpreter.fromAsset(_assetPath, options: options);
  }
}