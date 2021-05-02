import 'dart:ui';
import 'package:flutter/widgets.dart';



class Strokes with ChangeNotifier{

  Path _path;

  get path {
    return _path;
  }

  set path (Path p){
    _path = p;

    notifyListeners();
  }

  Strokes() {
    _path = Path();
  }

  void deleteAllStrokes(){
    _path.reset();

    notifyListeners();
  }

  void removeLastStroke(){
    
    // get all strokes except for the last one
    var p = _path.computeMetrics().take(_path.computeMetrics().length - 1);
    var newPath = Path();
    // copy the strokes to a new Path
    p.forEach((element) {
      newPath.addPath(element.extractPath(0, double.infinity), Offset.zero);
    });
    _path = newPath;

    notifyListeners();
  }

}