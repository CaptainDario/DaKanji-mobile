

import 'dart:ui';

import 'globals.dart';
import 'package:flutter/material.dart';


/// A class for defining the styling of theme dependent widgets. 
class Styling {

  Color predictionButtonColor;
  Color predictionButtonTextColor;
  Color kanjiBufferTextColor;
  Color installDialogueButtonColor;
  Color whatsNewButtonColor;

  Styling (){
    this.setTheme();
  }

  void setTheme () {
    if(SETTINGS.selectedTheme == "dark"){
      this.predictionButtonColor = Color.fromARGB(100, 150, 150, 150);
      this.predictionButtonTextColor = Colors.white;
      this.kanjiBufferTextColor = Colors.white;
      this.installDialogueButtonColor = Colors.black;
      this.whatsNewButtonColor = Color.fromARGB(100, 150, 150, 150);
    }

    else if(SETTINGS.selectedTheme == "light"){
      this.predictionButtonColor = Colors.lightBlue;
      this.predictionButtonTextColor = Colors.white;
      this.kanjiBufferTextColor = Colors.black;
      this.installDialogueButtonColor = Color.fromARGB(100, 150, 150, 150);
      this.whatsNewButtonColor = Colors.lightBlue;
    }
  }

}