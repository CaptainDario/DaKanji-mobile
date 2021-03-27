

import 'dart:ui';

import 'package:da_kanji_recognizer_mobile/globals.dart';
import 'package:flutter/material.dart';

class Styling {

  Color predictionButtonColor;
  Color predictionButtonTextColor;
  Color kanjiBufferTextColor;

  Styling (){
    this.setTheme();
  }

  void setTheme () {
    if(SETTINGS.selectedTheme == "dark"){
      this.predictionButtonColor = Color.fromARGB(100, 150, 150, 150);
      this.predictionButtonTextColor = Colors.white;
      this.kanjiBufferTextColor = Colors.white;
    }

    else if(SETTINGS.selectedTheme == "light"){
      this.predictionButtonColor = Colors.lightBlue;
      this.predictionButtonTextColor = Colors.white;
      this.kanjiBufferTextColor = Colors.black;
    }
  }

}