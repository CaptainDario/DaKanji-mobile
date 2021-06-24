import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:da_kanji_mobile/model/core/Screens.dart';
import 'package:da_kanji_mobile/provider/About.dart';
import 'package:da_kanji_mobile/view/DaKanjiDrawer.dart';
import 'package:da_kanji_mobile/view/ChangelogScreen.dart';


/// The "about"-screen
/// 
/// Shows the *about.md* and a link to the "changelog"-screen 
class AboutScreen extends StatelessWidget {

  /// was this page opened by clicking on the tab in the drawer
  final bool openedByDrawer;

  AboutScreen(this.openedByDrawer);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DaKanjiDrawer(
        currentScreen: Screens.about,
        animationAtStart: !this.openedByDrawer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image(image: AssetImage("media/banner.png"), width: 200,),
            // show the about.md
            Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 2),
              child: MarkdownBody(
                data: GetIt.I<About>().about,
                onTapLink: (text, url, title) {
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
                      "Show me the complete changelog.",
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
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 2),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if(await canLaunch(GetIt.I<About>().mobileStoreLink))
                          launch(GetIt.I<About>().mobileStoreLink);
                      }, 
                      child: Text("Rate this app")
                    ),
                  ),
                ],
              ),
            ),
          ]
        ),
      )
    );
  }
}
