import 'ChangelogScreen.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

import 'DaKanjiRecognizerDrawer.dart';
import 'globals.dart';


/// The "about"-screen
/// 
/// Shows the *about.md* and a link to the "changelog"-screen 
class AboutScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("About")),
      drawer: DaKanjiRecognizerDrawer(),
      body: Column(
        children: [
          // show the about.md
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
          // text with link to open the "changelog"-screen
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
