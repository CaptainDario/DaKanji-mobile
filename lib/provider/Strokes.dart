import 'dart:ui';
import 'package:flutter/widgets.dart';



class Strokes with ChangeNotifier{

  /// The path object of all strokes
  Path _path;
  /// How many strokes are there
  int _strokeCount;
  /// Is the animation to delete the last stroke currently running
  bool _deletingLastStroke;
  /// Is the animation to delete all strokes currently running
  bool _deletingAllStrokes;


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

  get deletingLastStroke{
    return _deletingLastStroke;
  }

  get deletingAllStrokes{
    return _deletingAllStrokes;
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
    _deletingLastStroke = false;
    _deletingAllStrokes = false;
  }

  /// Deletes all drawn strokes.
  void deleteAllStrokes(){
    _path.reset();
    _strokeCount = 0;

    _deletingAllStrokes = false;

    notifyListeners();
  }

  /// Deletes the last stroke of all drawn strokes.
  void deleteLastStroke(){
    
    // get all strokes except for the last one
    var p = _path.computeMetrics().take(_path.computeMetrics().length - 1);
    var newPath = Path();
    // copy the strokes to a new Path
    p.forEach((element) {
      newPath.addPath(element.extractPath(0, double.infinity), Offset.zero);
    });
    _path = newPath;

    decrementStrokeCount();

    _deletingLastStroke = false;

    notifyListeners();
  }

  /// Run the delete last strokes animation and delete the last stroke
  /// at the end.
  void deleteLastStrokeAnimation() {
    if(!deletingAllStrokes){
      _deletingLastStroke = true;
      notifyListeners();
    }
  }

  /// Run the delete all strokes animation and delete all strokes at the end.
  void deleteAllStrokesAnimation() {
    _deletingLastStroke = false;
    _deletingAllStrokes = true;
    notifyListeners();
  }

}