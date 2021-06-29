import 'package:da_kanji_mobile/provider/PlatformDependentVariables.dart';
import 'package:da_kanji_mobile/provider/UserData.dart';
import 'package:flutter/material.dart';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:da_kanji_mobile/locales_keys.dart';
import 'package:get_it/get_it.dart';
import 'package:in_app_review/in_app_review.dart';



/// Shows a rate popup which lets the user rate the app on the platform specific
/// app store.
/// 
/// The `context` should be the apps current context and `hasDoNotShowOption`
/// enables the option for the user to not show the rate popup again.
void showRatePopup(BuildContext context, bool hasDoNotShowOption){

  
  GetIt.I<UserData>().rateDialogueWasShown = true;

  AwesomeDialog(
    context: context,
    animType: AnimType.SCALE,
    dialogType: DialogType.QUESTION,
    headerAnimationLoop: false,
    body: Center(
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ask for a rating text
          Text(
            LocaleKeys.HomeScreen_RatePopup_text.tr(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 50,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // close button
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: 
                    MaterialStateProperty.all(
                      Color.fromARGB(100, 150, 150, 150)
                    )
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context, "/home", (Route<dynamic> route) => false);
                },
                child: Text(LocaleKeys.HomeScreen_RatePopup_close.tr())
              ),
              // do not ask again button
              if(hasDoNotShowOption)
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: 
                      MaterialStateProperty.all(
                        Color.fromARGB(100, 150, 150, 150)
                      )
                  ),
                  onPressed: () {
                    GetIt.I<UserData>().doNotShowRateAgain = true;
                    GetIt.I<UserData>().save();
                    Navigator.pushNamedAndRemoveUntil(
                      context, "/home", (Route<dynamic> route) => false);
                  },
                  child: Text(LocaleKeys.HomeScreen_RatePopup_dont_ask_again.tr())
                ),
              // rate button
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: 
                    MaterialStateProperty.all(
                      Color.fromARGB(100, 150, 150, 150)
                    )
                ),
                onPressed: () async {
                  final InAppReview inAppReview = InAppReview.instance;

                  if (await inAppReview.isAvailable()) {
                    inAppReview.requestReview();
                  }
                  else{
                    // TODO: add store id's
                    inAppReview.openStoreListing(
                      appStoreId: '...', 
                      microsoftStoreId: '...'
                    );
                  }
                },
                child: Text(LocaleKeys.HomeScreen_RatePopup_rate.tr())
              ),
            ],
          )
        ],
      )
    )
  )..show();

}