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
            padding: EdgeInsets.all(16),
            child: MarkdownBody(
              data: ABOUT,
              onTapLink: (text, url, title) {
                print((text + " " + url + " " + title));
                launch(url);
              },
            )
          ),
          Row(
            children:[
              Expanded(
                flex: 1,
                child: MaterialButton(
                  onPressed: (){
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => ChangelogScreen()),
                    );
                  },
                  child: Text(
                    "Show me the changelog",
                    textAlign: TextAlign.left,
                  ),
                )
              )
            ]
          )
        ]
      ),
    );
  }
}
