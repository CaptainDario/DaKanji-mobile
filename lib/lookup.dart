
import 'package:flutter/foundation.dart';

/// Class which notifies its listeners always when [_value] changed.
class Lookup with ChangeNotifier{
  
  /// the character which be searched in a dictionary
  String _chars;

  /// is the animation for adding a new character running
  String _url;

  /// initializes a new [KanjiBuffer] instance
  Lookup() {
    _chars = "";
    _url = "";
  }

  /// returns the current value
  String get chars{
    return _chars;
  }

  /// set the current value to [value] and notify listeners
  set chars(String value){
    _chars = value;
    notifyListeners();
  }

}