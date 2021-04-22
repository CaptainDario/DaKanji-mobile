import 'package:flutter/foundation.dart';

/// Class which notifies its listeners always when [_value] changed.
class KanjiBuffer with ChangeNotifier{
  
  /// the current string of this class
  String _value;

  /// is the animation for adding a new character running
  bool runAnimation = false;

  /// initializes a new [KanjiBuffer] instance
  KanjiBuffer() {
    _value = "";
  }

  /// returns the current value
  String get kanjiBuffer{
    return _value;
  }

  /// set the current value to [value] and notify listeners
  set kanjiBuffer(String value){
    _value = value;
    notifyListeners();
  }

  /// removes the last char from the current value and notifies listeners
  void removeLastChar(){
    _value = _value.substring(0, _value.length - 1);
  }
}