import 'dart:io' show Platform;

import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_appavailability/flutter_appavailability.dart';

import 'globals.dart';


/// A convenience class to handle long and short press for the predictions.
class HandlePrediction{

  static final HandlePrediction _instance = HandlePrediction._internal();
  factory HandlePrediction() => _instance;

  HandlePrediction._internal();

  void handlePress(bool longPress, BuildContext context, String char){

    // presses should be inverted
    if(SETTINGS.invertShortLongPress){
      if(!longPress)
        handleLongPress(context, char);
      else
        handleShortPress(context, char);
    }
    // presses should NOT be inverted
    if(!SETTINGS.invertShortLongPress){
      if(!longPress)
        handleShortPress(context, char);
      else
        handleLongPress(context, char);
    }
  }


  /// Copy char to the system clipboard and show a snackbar using context
  /// 
  /// @params context to use to show the snackbar 
  /// @params the string which should be copied to the clipboard
  void handleShortPress(BuildContext context, String char){
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

  void handleLongPress(BuildContext context, String char) async {

    // only open a page when there is a prediction
    if (char != " " && char != "") {
      // the prediction should be translated with system dialogue
      if(SETTINGS.selectedDictionary == SETTINGS.dictionaries[4]){ 
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
      else if(SETTINGS.selectedDictionary == SETTINGS.dictionaries[5]){
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
      else if(SETTINGS.selectedDictionary == SETTINGS.dictionaries[6]){
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
      else if(SETTINGS.selectedDictionary == SETTINGS.dictionaries[7]){
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
        launch(SETTINGS.openWithSelectedDictionary(char));
      }
    }
  }

  void showDownloadDialogue(
    BuildContext context, String title, String text, String url){

    showDialog(
      context: context,
      builder: (BuildContext context){ 
        return SimpleDialog(
          title: Center(child: Text(title)),
          children: [
            Center(child:
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style:
                      ButtonStyle(
                        backgroundColor: 
                          MaterialStateProperty
                            .all(CURRENT_STYLING.installDialogueButtonColor)
                      ),
                    onPressed: () async {
                      launch(url);
                    },
                    child: Text(text)
                  ),
                  SizedBox(width: 10,),
                  ElevatedButton(
                    style:
                      ButtonStyle(
                        backgroundColor: 
                          MaterialStateProperty
                            .all(CURRENT_STYLING.installDialogueButtonColor)
                      ),
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    child: Text("Close")
                  ),
                ]
              )
            ))
          ],
        );
      }
    );
  }
}