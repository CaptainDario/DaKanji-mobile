import 'package:da_kanji_recognizer_mobile/ChangelogScreen.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
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
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 2),
            child: MarkdownBody(
              data: ABOUT,
              onTapLink: (text, url, title) {
                print((text + " " + url + " " + title));
                launch(url);
              },
            ),
          ),
          Row(
            children:[
              Container(
                padding: EdgeInsets.fromLTRB(16, 2, 16, 0),
                child: GestureDetector(
                  child: Text(
                    "Show me the changelog.",
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.blue),
                  ),
                  onTap: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => ChangelogScreen()),
                  )
                )
              )
            ]
          )
        ]
      ),
    );
  }
}
