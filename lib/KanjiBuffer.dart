import 'package:flutter/foundation.dart';

class KanjiBuffer with ChangeNotifier{
  String _value;

  KanjiBuffer() {
    _value = "";
  }

  String get kanjiBuffer{
    return _value;
  }

  set kanjiBuffer(String value){
    _value = value;
    notifyListeners();
  }

  void removeLastChar(){
    _value = _value.substring(0, _value.length - 1);
    notifyListeners();
  }
}