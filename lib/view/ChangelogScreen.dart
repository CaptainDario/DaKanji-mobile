import 'package:da_kanji_mobile/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';


/// The "changelog"-screen.
/// 
/// Shows the complete CHANGELOG.md 
class ChangelogScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text(APP_TITLE + " - Changelog"),),
      body: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Center(
          child: 
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Expanded(
                    child: Markdown(
                      data: WHOLE_CHANGELOG,
                      selectable: false,
                      onTapLink: 
                      (String text, String url, String title) async {
                        if(await canLaunch(url))
                          launch(url);
                      },
                    )
                  ),
                ]
              )
            )
        ),
      ),
    );
  }
}
