
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';

import 'globals.dart';


StreamSubscription linkSub;

Future<Null> initDeepLinksStream() async {
  // ... check initialUri

  // Attach a listener to the stream
  linkSub = getLinksStream().listen((String link) {

    print("Stream: "+ (link ?? "none"));
    handleLink(link);

  },
  onError: (err) {
    print("An error occurred handling the DeepLink stream!");
  });
}

/// 
Future<Null> getInitialDeepLink() async {
  
  try {
    String initialLink = await getInitialLink();
    print("Initial Link: " + (initialLink ?? "none"));
    handleLink(initialLink);
  }
  on PlatformException {
    print("Not started by DeepLink.");
  }
}

void handleLink(String link){

  if(link == null) return;

  String short = link.replaceFirst(APP_LINK, "");

  if(short.contains("jisho")){
    print("contains jisho");
    SETTINGS.selectedDictionary = SETTINGS.dictionaries[0];
  }
  else if(short.contains("wadoku")){
    print("contains wadoku");
    SETTINGS.selectedDictionary = SETTINGS.dictionaries[1];
  }
  else if(short.contains("weblio")){
    print("contains weblio");
    SETTINGS.selectedDictionary = SETTINGS.dictionaries[2];
  }
  else if(short.contains("URL")){
    print("contains URL");
    SETTINGS.selectedDictionary = SETTINGS.dictionaries[3];
  }
  else if(short.contains("aedict")){
    print("contains aedict");
    SETTINGS.selectedDictionary = SETTINGS.dictionaries[5];
  }
  else if(short.contains("akebi")){
    print("contains akebi");
    SETTINGS.selectedDictionary = SETTINGS.dictionaries[6];
  }
  else if(short.contains("takoboto")){
    print("contains takoboto");
    SETTINGS.selectedDictionary = SETTINGS.dictionaries[7];
  }
  else{
    print("No matching dictionary found!");
  }
}
