import 'package:flutter/material.dart';

import 'package:awesome_dialog/awesome_dialog.dart';


/// Shows a rate popup which lets the user rate the app on the platform specific
/// app store.
/// 
/// The `context` should be the apps current context and `hasDoNotShowOption`
/// enables the option for the user to not show the rate popup again.
void showRatePopup(BuildContext context, bool hasDoNotShowOption){

  AwesomeDialog(
    context: context,
    animType: AnimType.SCALE,
    dialogType: DialogType.INFO,
    headerAnimationLoop: false,
    body: Text("test")
  )..show();

}