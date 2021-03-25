

import 'package:flutter/cupertino.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class ShowcaseTuple {

  GlobalKey key;
  String title;
  String text;
  ContentAlign align;

  ShowcaseTuple(GlobalKey item1, String item2, String item3, ContentAlign item4){
    this.key = item1;
    this.title = item2;
    this.text = item3;
    this.align = item4;
  }
}