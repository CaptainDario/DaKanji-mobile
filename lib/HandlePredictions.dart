import 'dart:io' show Platform;

import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'globals.dart';


/// A convenience class to handle long and short press for the predictions.
class HandlePrediction{

  static final HandlePrediction _instance = HandlePrediction._internal();
  factory HandlePrediction() => _instance;

  HandlePrediction._internal();


  /// Copy char to the system clipboard and show a snackbar using context
  /// 
  /// @params context to use to show the snackbar 
  /// @params the string which should be copied to the clipboard
  void handlePress(BuildContext context, String char){
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
      if(SETTINGS.openWithDefaultTranslator){ 
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
            showDialog(
              context: context,
              builder: (BuildContext context){ 
                return SimpleDialog(
                  title: Center(child: Text("No translator installed")),
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          MaterialButton(
                            color: Colors.white.withAlpha(50),
                            onPressed: () {
                              launch(PLAYSTORE_BASE_URL + GOOGLE_TRANSLATE_ID);
                            },
                            child: Text("Download Google Translate")
                          ) 
                        ]
                      )
                    )
                  ],
                );
              }
            );
          }
        }
        else if(Platform.isIOS && false){
          print("iOS is not implemented for choosing translator");
        }
      }
      // offline dictionary takoboto (android)
      else if(SETTINGS.openWithTakoboto){
        if(Platform.isAndroid){
          AndroidIntent intent = AndroidIntent(
              package: 'jp.takoboto',
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
              "Download Takoboto", 
              PLAYSTORE_BASE_URL + TAKOBOTO_ID
            );
          }
        }
      }
      // offline dictionary akebi (android)
      else if(SETTINGS.openWithAkebi){
        if(Platform.isAndroid){
          AndroidIntent intent = AndroidIntent(
              package: 'com.craxic.akebifree',
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
              "Download Akebi", 
              PLAYSTORE_BASE_URL + AKEBI_ID
            );
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
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  MaterialButton(
                    color: Colors.white.withAlpha(50),
                    onPressed: () async {
                      launch(url);
                    },
                    child: Text(text)
                  ) 
                ]
              )
            )
          ],
        );
      }
    );
  }
}