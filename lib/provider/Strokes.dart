import 'dart:ui';
import 'package:flutter/widgets.dart';



class Strokes with ChangeNotifier{

  /// The path object of all strokes
  Path _path;
  /// How many strokes are there
  int _strokeCount; 


  get path {
    return _path;
  }

  set path (Path p){
    _path = p;

    notifyListeners();
  }
  
  get strokeCount {
    return _strokeCount;
  }

  void incrementStrokeCount(){
    _strokeCount++;
  }
  
  void decrementStrokeCount(){
    _strokeCount--;
  }

  Strokes() {
    _path = Path();
    _strokeCount = 0;
  }

  /// Deletes all drawn strokes.
  void deleteAllStrokes(){
    _path.reset();
    _strokeCount = 0;

    notifyListeners();
  }

  /// Deletes the last stroke of all drawn strokes.
  void removeLastStroke(){
    
    // get all strokes except for the last one
    var p = _path.computeMetrics().take(_path.computeMetrics().length - 1);
    var newPath = Path();
    // copy the strokes to a new Path
    p.forEach((element) {
      newPath.addPath(element.extractPath(0, double.infinity), Offset.zero);
    });
    _path = newPath;

    decrementStrokeCount();

    notifyListeners();
  }

}