import 'package:da_kanji_recognizer_mobile/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';


class ChangelogScreen extends StatefulWidget {
  @override
  _ChangelogScreenState createState() => _ChangelogScreenState();
}

class _ChangelogScreenState extends State<ChangelogScreen> {

  bool showChangelog = true;

  @override
  void initState() { 
    super.initState();
  }

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
                    child: Markdown(data: WHOLE_CHANGELOG)
                  ),
                ]
              )
            )
        ),
      ),
    );
  }
}
