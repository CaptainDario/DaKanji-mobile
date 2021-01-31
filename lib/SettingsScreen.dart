import 'package:flutter/material.dart';

import 'package:da_kanji_recognizer_mobile/DaKanjiRecognizerDrawer.dart';
import 'globals.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void toggleSwitches(int switchToBeTrue) {
    SETTINGS.setTogglesToFalse();

    switch (switchToBeTrue) {
      case 1:
        SETTINGS.openWithJisho = true;
        break;

      case 2:
        SETTINGS.openWithTakoboto = true;
        break;

      case 3:
        SETTINGS.openWithWadoku = true;
        break;

      case 4:
        SETTINGS.openWithCustomURL = true;
        break;
    }

    SETTINGS.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Settings")),
        drawer: DaKanjiRecognizerDrawer(),
        // ListView of all available settings
        body: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[

            // different options for dictionary on long press
            ListTile(title: Text("Long press opens:")),
            ListTile(
                title: Text("on jisho.org"),
                trailing: Switch(
                    value: SETTINGS.openWithJisho,
                    onChanged: (value) {
                      setState(() {
                        toggleSwitches(1);
                      });
                    }),
                onTap: () {}),
            ListTile(
                title: Text("on takoboto.jp"),
                trailing: Switch(
                    value: SETTINGS.openWithTakoboto,
                    onChanged: (value) {
                      setState(() {
                        toggleSwitches(2);
                      });
                    }),
                onTap: () {}),
            ListTile(
                title: Text("on wadoku.de"),
                trailing: Switch(
                    value: SETTINGS.openWithWadoku,
                    onChanged: (value) {
                      setState(() {
                        toggleSwitches(3);
                      });
                    }),
                onTap: () {}),
            // let the user enter a custom url for flexibility
            ListTile(
                title: Text("a custom URL"),
                trailing: Switch(
                    value: SETTINGS.openWithCustomURL,
                    onChanged: (value) {
                      setState(() {
                        toggleSwitches(4);
                      });
                    }),
                onTap: () {}),
            ListTile(
                title: Row(children: [
                  Container(
                      child: Expanded(
                          child: TextField(
                    enabled: SETTINGS.openWithCustomURL,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: SETTINGS.customURL),
                    onChanged: (value) {
                      SETTINGS.customURL = value;
                      SETTINGS.save();
                    },
                  )))
                ]),
                onTap: () {}),
            // setting for which theme to use
            ListTile(
                title: Text("theme (set with next app start)"),
                trailing: DropdownButton<String>(
                  value: SETTINGS.selectedTheme,
                  items: SETTINGS.themes
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                        value: value, child: Text(value));
                  }).toList(),
                  onChanged: (String newValue) {
                    setState(() {
                      SETTINGS.selectedTheme = newValue;
                      SETTINGS.save();
                    });
                  },
                ),
                onTap: () {}),
          ],
        ));
  }
}
