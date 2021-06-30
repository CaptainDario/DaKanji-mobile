import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter_appavailability/flutter_appavailability.dart';
import 'package:get_it/get_it.dart';

import 'package:da_kanji_mobile/globals.dart';
import 'package:da_kanji_mobile/provider/Lookup.dart';
import 'package:da_kanji_mobile/provider/Settings.dart';
import 'package:da_kanji_mobile/view/DownloadAppDialogue.dart';
import 'package:da_kanji_mobile/view/WebviewScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_io/io.dart' show Platform;


/// A convenience class to handle long and short press for the predictions.
class HandlePrediction{

  static final HandlePrediction _instance = HandlePrediction._internal();
  factory HandlePrediction() => _instance;

  HandlePrediction._internal();

  void handlePress(BuildContext context){

    // presses should be inverted
    if(GetIt.I<Settings>().invertShortLongPress){
      if(!GetIt.I<Lookup>().longPress)
        openDictionary(context, GetIt.I<Lookup>().chars);
      else
        copy(context, GetIt.I<Lookup>().chars);
    }
    // presses should NOT be inverted
    if(!GetIt.I<Settings>().invertShortLongPress){
      if(!GetIt.I<Lookup>().longPress)
        copy(context, GetIt.I<Lookup>().chars);
      else
        openDictionary(context, GetIt.I<Lookup>().chars);
    }
  }


  /// Copies [char] to the system clipboard and show a snackbar using [context].
  void copy(BuildContext context, String char){
    if (char != " " && char != ""){
      Clipboard.setData(new ClipboardData(text: char));
      // display a snackbar for 1s 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          content: Text("copied " + char + " to clipboard"),
        )
      );
    }
  }

  /// Open [char] in the dictionary selected in the settings.
  /// 
  /// If the selected dictionary is not installed show a dialogue to ask the 
  /// user if he/she wants to download it.
  void openDictionary(BuildContext context, String char) async {

    // only open a page when there is a prediction
    if (char != " " && char != "") {
      // the prediction should be translated with system dialogue
      if(GetIt.I<Settings>().selectedDictionary == GetIt.I<Settings>().dictionaries[3]){ 
        if(Platform.isAndroid){
          AndroidIntent intent = AndroidIntent(
            action: 'android.intent.action.TRANSLATE',
            arguments: <String, dynamic>{
              "android.intent.extra.TEXT" : char
            }
          );
          if(await intent.canResolveActivity())
            await intent.launch();
          else{
            showDownloadDialogue(
              context,
              "No translator installed", 
              "Download",
              PLAYSTORE_BASE_URL + GOOGLE_TRANSLATE_ID
            );
          }
        }
        else if(Platform.isIOS){
          print("iOS is not implemented for choosing translator");
        }
      }
      // offline dictionary aedict3 (android)
      else if(GetIt.I<Settings>().selectedDictionary == GetIt.I<Settings>().dictionaries[4]){
        if(Platform.isAndroid){
          try{
            // make sure the package is installed
            await AppAvailability.checkAvailability(AEDICT_ID);
            
            AndroidIntent intent = AndroidIntent(
                package: AEDICT_ID,
                type: "text/plain",
                action: 'android.intent.action.SEND',
                category: 'android.intent.category.DEFAULT',
                arguments: <String, dynamic>{
                  "android.intent.extra.TEXT": char,
                }
            );
            if(await intent.canResolveActivity())
              await intent.launch();
          }
          catch (e){
            showDownloadDialogue(context,
              "Aedict not installed", 
              "Download", 
              PLAYSTORE_BASE_URL + AEDICT_ID 
            );
          }
        }
      }
      // offline dictionary akebi (android)
      else if(GetIt.I<Settings>().selectedDictionary == GetIt.I<Settings>().dictionaries[5]){
        if(Platform.isAndroid){
          AndroidIntent intent = AndroidIntent(
              package: AKEBI_ID,
              componentName: 
                'com.craxic.akebifree.activities.search.SearchActivity',
              type: "text/plain",
              action: 'android.intent.action.SEND',
              arguments: <String, dynamic>{
                "android.intent.extra.TEXT": char,
              }
          );
          if(await intent.canResolveActivity())
            await intent.launch();
          else
            showDownloadDialogue(context,
              "Akebi not installed", 
              "Download", 
              PLAYSTORE_BASE_URL + AKEBI_ID
            );
        }
      }
      // offline dictionary takoboto (android)
      else if(GetIt.I<Settings>().selectedDictionary == GetIt.I<Settings>().dictionaries[6]){
        if(Platform.isAndroid){
          AndroidIntent intent = AndroidIntent(
              package: TAKOBOTO_ID,
              action: 'jp.takoboto.SEARCH',
              arguments: <String, dynamic>{
                "android.intent.extra.PROCESS_TEXT": char,
              }
          );
          if(await intent.canResolveActivity())
            await intent.launch();
          else{
            showDownloadDialogue(context,
              "Takoboto not installed", 
              "Download", 
              PLAYSTORE_BASE_URL + TAKOBOTO_ID
            );
          }
        }
      }
      else{
        // use the default browser
        if(!GetIt.I<Settings>().useWebview)
          launch(openWithSelectedDictionary(char));
        else
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (BuildContext context) => WebviewScreen()
            )
          );
      }
    }
  }


  /// Get the URL to the predicted kanji in the selected dictionary.
  ///
  /// @returns The URL which leads to the predicted kanji in the selected dict.
  String openWithSelectedDictionary(String kanji) {
    String url;

    // determine which URL should be used for finding the character
    if(GetIt.I<Settings>().selectedDictionary == GetIt.I<Settings>().dictionaries[0])
      url = GetIt.I<Settings>().jishoURL;
    else if(GetIt.I<Settings>().selectedDictionary == GetIt.I<Settings>().dictionaries[1])
      url = GetIt.I<Settings>().wadokuURL;
    else if(GetIt.I<Settings>().selectedDictionary == GetIt.I<Settings>().dictionaries[2])
      url = GetIt.I<Settings>().weblioURL;
    else if(GetIt.I<Settings>().selectedDictionary == GetIt.I<Settings>().dictionaries[3])
      url = GetIt.I<Settings>().customURL;

    if(url != null){
      // check that the URL starts with protocol, otherwise launch() fails
      if (!(url.startsWith("http://") || url.startsWith("https://")))
        url = "https://" + url;

      // replace the placeholder with the actual character
      url =
        url.replaceFirst(new RegExp(GetIt.I<Settings>().kanjiPlaceholder), kanji);
      url = Uri.encodeFull(url);
    }
    return url;
  }

}