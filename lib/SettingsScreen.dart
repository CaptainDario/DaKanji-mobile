import 'dart:io' show Platform;
import 'dart:ui';

import 'package:da_kanji_recognizer_mobile/DaKanjiRecognizerDrawer.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool openInJisho = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Settings")),
        drawer: DaKanjiRecognizerDrawer(),
        body: ListView(padding: EdgeInsets.zero, children: <Widget>[
          ListTile(
              title: Text("Open in Jisho"),
              trailing: Switch(
                  value: openInJisho,
                  onChanged: (value) {
                    setState(() {
                      openInJisho = value;
                    });
                  }),
              onTap: () {}),
        ]));
  }
}
