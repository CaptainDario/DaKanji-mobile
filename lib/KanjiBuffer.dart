import 'package:flutter/foundation.dart';

class KanjiBuffer with ChangeNotifier{
  static final KanjiBuffer _instance = KanjiBuffer._internal();

  factory KanjiBuffer() => _instance;
  String _value;

  KanjiBuffer._internal() {
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