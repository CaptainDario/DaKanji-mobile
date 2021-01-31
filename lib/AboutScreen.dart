import 'dart:ui';

import 'package:url_launcher/url_launcher.dart';

import 'package:da_kanji_recognizer_mobile/DaKanjiRecognizerDrawer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

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
                      text: "in this repository.\n\n",
                      style: TextStyle(color: Colors.blue),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () {
                          launch(
                              "https://github.com/CaptainDario/DaKanjiRecognizer");
                        }),
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
                        ..onTap = () {
                          launch(
                              "https://github.com/CaptainDario/DaKanjiRecognizer-Mobile");
                        }),
                  TextSpan(
                      text:
                          "If you want to learn more about the CNN (AI) powering this app, "),
                  TextSpan(
                      text: "take a look at this jupyter notebook.\n\n",
                      style: TextStyle(color: Colors.blue),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () {
                          launch(
                              "https://captaindario.github.io/DaKanjiRecognizer/DaKanjiRecognizer.html");
                        }),
                  TextSpan(text: "If you like this app please consider\n"),
                  TextSpan(text: "\t • "),
                  TextSpan(
                      text: "rating it on Google Play ADD LINK HERE LATER\n",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () {
                          launch(
                              "https://github.com/CaptainDario/DaKanjiRecognizer-Mobile");
                        }),
                  TextSpan(text: "\t • "),
                  TextSpan(
                      text: "starring it on GitHub \n\n",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () {
                          launch(
                              "https://github.com/CaptainDario/DaKanjiRecognizer");
                        }),
                  TextSpan(text: "And also check out \n"),
                  TextSpan(text: "\t • "),
                  TextSpan(
                      text: "my other apps (Play Store)",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () {
                          launch(
                              "https://play.google.com/store/apps/developer?id=DaAppLab&hl=en&gl=US");
                        }),
                  TextSpan(text: "\n\t • "),
                  TextSpan(
                      text: "instructables",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () {
                          launch(
                              "https://www.instructables.com/member/daapplab/");
                        }),
                  TextSpan(text: "\n\t • "),
                  TextSpan(
                      text: "videos ",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () {
                          launch(
                              "https://play.google.com/store/apps/developer?id=DaAppLab&hl=en&gl=US");
                        }),
                  TextSpan(text: "\n\t • "),
                  TextSpan(
                      text: "open source projects",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () {
                          launch("https://github.com/CaptainDario");
                        }),
                  TextSpan(
                      text:
                          "\n\nIf you have a problem using this app please open an issue "),
                  TextSpan(
                      text: "here.",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () {
                          launch(
                              "https://github.com/CaptainDario/DaKanjiRecognizer-Mobile/issues/new");
                        }),
                  TextSpan(
                      text:
                          "\nYou have an awseome idea how to improve this app?"),
                  TextSpan(text: "That's awesome! Let's discuss it "),
                  TextSpan(
                      text: "here.",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () {
                          launch(
                              "https://github.com/CaptainDario/DaKanjiRecognizer-Mobile/issues/new");
                        }),
                  TextSpan(text: "\nThe privacy police can be found "),
                  TextSpan(
                      text: "here. LINK HERE LATER",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () {
                          launch(
                              "https://github.com/CaptainDario/DaKanjiRecognizer-Mobile/");
                        }),
                ]),
          )),
    );
  }
}
