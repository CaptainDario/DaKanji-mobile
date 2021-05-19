import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:get_it/get_it.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'package:da_kanji_mobile/model/core/Showcase.dart';
import 'package:da_kanji_mobile/model/core/ShowcaseTuple.dart';
import 'package:da_kanji_mobile/provider/Settings.dart';
import 'package:da_kanji_mobile/provider/DrawerListener.dart';
import 'package:da_kanji_mobile/globals.dart';


/// The showcase of the features of the draw screen.
class DrawScreenShowcase extends Showcase {


  /// Initialize the elements which should be shown in the showcase
  DrawScreenShowcase () {

    SHOWCASE_DRAWING = [
      // 0 - Drawing canvas
      ShowcaseTuple(GlobalKey(), "Drawing",
        "Draw a character here", ContentAlign.bottom),
      // 1 - undo last stroke
      ShowcaseTuple(GlobalKey(), "Undo", 
        "Press to undo the last stroke", ContentAlign.bottom), 
      // 2 - clear canvas
      ShowcaseTuple(GlobalKey(), "Clear", 
        "Erase all strokes", ContentAlign.bottom), 
      // 3 - prediction buttons
      ShowcaseTuple(GlobalKey(), "Predictions", 
        "The predicted characters will be shown here", ContentAlign.top), 
      // 4 - short press prediction button
      ShowcaseTuple(GlobalKey(), "Short Press Prediction",
        "A short press copies the prediction", ContentAlign.bottom), 
      // 5 - long press prediction button
      ShowcaseTuple(GlobalKey(), "Long Press Prediction",
        "A long press opens the prediction in a dictionary", ContentAlign.bottom), 
      // 6 - multi search box
      ShowcaseTuple(GlobalKey(), "Multi search",
        "Here you can search multiple characters at once", ContentAlign.bottom), 
      // 7 - double tap prediction button
      ShowcaseTuple(GlobalKey(), "Double Tap Prediction",
        "A Double Tap adds the character to the search box", ContentAlign.bottom), 
      // 8 - multi search short press 
      ShowcaseTuple(GlobalKey(), "Multi search short press",
        "A short press copies the characters to the clipboard", ContentAlign.bottom), 
      // 9 - multi search long press
      ShowcaseTuple(GlobalKey(), "Multi search long press",
        "A long press opens the characters in a dictionary", ContentAlign.bottom), 
      // 10 - multi search double tap
      ShowcaseTuple(GlobalKey(), "Multi search double tap",
        "A double tap empties the field", ContentAlign.bottom), 
      // 11 - multi search swipe left
      ShowcaseTuple(GlobalKey(), "Multi search swipe left",
        "Swiping left on this field deletes the last character", ContentAlign.bottom), 
      // 12 - change dict in settings
      ShowcaseTuple(GlobalKey(), "Dictionary Settings",
        "In the settings the translation service can be chosen", ContentAlign.bottom), 
    ];

  }

  /// Initialize the elements of the showcase.
  /// Should return a list of all targets.
  @protected
  List<TargetFocus> initTargets() {

    List<TargetFocus> targets = [];
    // canvas
    targets.add(createShowcaseTargetFocus(0));
    // undo button
    targets.add(createShowcaseTargetFocus(1));
    // clear button 
    targets.add(createShowcaseTargetFocus(2));
    // predictions
    targets.add(createShowcaseTargetFocus(3));
    // short press prediction button
    targets.add(createShowcaseTargetFocus(4));
    // long press prediction button
    targets.add(createShowcaseTargetFocus(5, keyIndex: 4));
    // multi char
    targets.add(createShowcaseTargetFocus(6));
    //double tap prediction button 
    targets.add(createShowcaseTargetFocus(7, keyIndex: 4));
    // short press multi char
    targets.add(createShowcaseTargetFocus(8, keyIndex: 6));
    // long press multi char
    targets.add(createShowcaseTargetFocus(9, keyIndex: 6));
    // double tap multi char
    targets.add(createShowcaseTargetFocus(10, keyIndex: 6));
    // double tap
    targets.add(createShowcaseTargetFocus(11, keyIndex: 6));
    // show settings
    targets.add(createShowcaseTargetFocus(12)
    );

    return targets;
  }

  /// Creates one `TargetFocus` element based on the element at place [index]
  /// in [SHOWCASE_DRAWING] and returns it.
  /// [keyIndex] can be used to use a different index 
  /// for the `GlobalKey` of the widget to show 
  @protected
  TargetFocus createShowcaseTargetFocus(int index, {int keyIndex}){
    return TargetFocus(
      identify: SHOWCASE_DRAWING[index].title,
      shape: ShapeLightFocus.RRect,
      color: vignetteColor,
      keyTarget: SHOWCASE_DRAWING[keyIndex ?? index].key,
      contents: [
        TargetContent(
          align: SHOWCASE_DRAWING[index].align,
          child: Container(
            child: Text(
              SHOWCASE_DRAWING[index].text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20.0
              ),
            ),
          )
        )
      ],
    );
  }
  
  /// Initializes a `TutorialCoachMark` instance with the showcase for the 
  /// DrawScreen for the given [context].
  @protected
  TutorialCoachMark initShowcase(BuildContext context) {
    return TutorialCoachMark(
      context,
      targets: this.targets,
      colorShadow: Colors.red,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        // close the drawer
        GetIt.I<DrawerListener>().playReverse = true; 

        // don't show the tutorial again
        SHOW_SHOWCASE_DRAWING = false;
        GetIt.I<Settings>().save();
      },
      onClickTarget: (target) {
        // open drawer after clicking on the second last showcase
        if(target.identify == SHOWCASE_DRAWING[11].title)
          GetIt.I<DrawerListener>().playForward = true; 
      },
      onSkip: () {
        // don't show the tutorial again
        SHOW_SHOWCASE_DRAWING = false;
        GetIt.I<Settings>().save();
      },
      onClickOverlay: (target) {},
    );
  }

}