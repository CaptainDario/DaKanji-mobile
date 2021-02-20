import 'dart:io';
import 'dart:io' show Platform;
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:da_kanji_recognizer_mobile/DaKanjiRecognizerDrawer.dart';
import 'globals.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("About")),
      drawer: DaKanjiRecognizerDrawer(),
      body: Container(
        padding: EdgeInsets.all(5),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 16,
              color: (Theme.of(context).brightness == Brightness.dark)
                      ? Colors.white
                      : Colors.black
            ),
            children: [
              TextSpan(
                text: "This is an open source Kanji Recognizer app. "),
              TextSpan(
                text: "It can recognize handwritten Kanji characters.\n"),
              TextSpan(text: "A desktop version is available "),
              TextSpan(
                text: "here.\n\n",
                style: TextStyle(color: Colors.blue),
                recognizer: new TapGestureRecognizer()
                  ..onTap = () => launch(GITHUB_DESKTOP_REPO)),
              TextSpan(
                text:
                    "The UI was developed using dart and the Flutter framework. "),
              TextSpan(
                text:
                    "If you want to learn more about the development of the app, "),
              TextSpan(
                text: "visit its GitHub repository.\n\n",
                style: TextStyle(color: Colors.blue),
                recognizer: new TapGestureRecognizer()
                  ..onTap = () => launch(GITHUB_MOBILE_REPO)),
              TextSpan(
                text:
                    "If you want to learn more about the machine learning powering this app, "),
              TextSpan(
                text: "take a look here.\n\n",
                style: TextStyle(color: Colors.blue),
                recognizer: new TapGestureRecognizer()
                  ..onTap = () => launch(GITHUB_ML_REPO)),
              TextSpan(text: "If you like this app please consider\n"),
              TextSpan(text: "\t • "),
              TextSpan(
                text: RATE_ON_MOBILE_STORE,
                style: TextStyle(
                  color: Colors.blue,
                ),
                recognizer: new TapGestureRecognizer()
                  ..onTap = () {
                    if(Platform.isAndroid) launch(PLAYSTORE_PAGE);
                    else if(Platform.isIOS) launch(APPSTORE_PAGE);
                    else launch(PLAYSTORE_PAGE);
                  }),
              TextSpan(text: "\n\t • "),
              TextSpan(
                text: "starring it on GitHub \n\n",
                style: TextStyle(
                  color: Colors.blue,
                ),
                recognizer: new TapGestureRecognizer()
                  ..onTap = () => launch(GITHUB_MOBILE_REPO)
              ),
              TextSpan(text: "Also check out "),
              TextSpan(
                text: "my other apps (Play Store / AppStore)",
                style: TextStyle(
                  color: Colors.blue,
                ),
                recognizer: new TapGestureRecognizer()
                  ..onTap = () {
                    if(Platform.isAndroid) launch(DAAPPLAB_PLAYSTORE_PAGE);
                    else if(Platform.isIOS) launch(DAAPPLAB_APPSTORE_PAGE);
                    else launch(DAAPPLAB_PLAYSTORE_PAGE);
                  }),
              TextSpan(
                text:
                    "\n\nIf you have a problem using this app please report it "),
              TextSpan(
                text: "here.",
                style: TextStyle(
                  color: Colors.blue,
                ),
                recognizer: new TapGestureRecognizer()
                  ..onTap = () => launch(GITHUB_ISSUES)
                  ),
              TextSpan(
                text:
                    "\nYou have an idea how to improve this app?"),
              TextSpan(text: "That's awesome! Let's discuss it "),
              TextSpan(
                text: "here.",
                style: TextStyle(
                  color: Colors.blue,
                ),
                recognizer: new TapGestureRecognizer()
                  ..onTap = () => launch(GITHUB_ISSUES)),
              TextSpan(text: "\nThe privacy police can be found "),
              TextSpan(
                text: "here. LINK HERE LATER",
                style: TextStyle(
                  color: Colors.blue,
                ),
                recognizer: new TapGestureRecognizer()
                  ..onTap = () => launch(PRIVACY_POLICE)
              ),
              TextSpan(text: "\n\nThe used backend for inference is: " + USED_BACKEND),
            ]
          ),
        )
      ),
    );
  }
}
