import 'package:flutter/material.dart';

import 'package:da_kanji_recognizer_mobile/DaKanjiRecognizerDrawer.dart';
import 'globals.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

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
          ListTile(
            title: Text(
              "Drawing single character", 
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18
              ),
            )
          ),
          ListTile(
            title: Text("Long press opens"),
            trailing: DropdownButton<String>(
              value: SETTINGS.selectedDictionary,
              items: SETTINGS.dictionaries 
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                    value: value, child: Text(value));
              }).toList(),
              onChanged: (String newValue) {
                setState(() {
                  print(newValue);
                  SETTINGS.setDictionary(newValue);
                  SETTINGS.save();
                });
              },
            ),
            onTap: (){},
          ),
          // let the user enter a custom url for flexibility
          ListTile(
            title: Row(
              children: [
                Container(
                  child: Expanded(
                    child: TextField(
                      enabled: SETTINGS.openWithCustomURL,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: SETTINGS.customURL,
                        hintText: "URL of your dictionary"), 
                      onChanged: (value) {
                        SETTINGS.customURL = value;
                        SETTINGS.save();
                      },
                    )
                  )
                )
              ]
            ),
              onTap: () {}),
          Divider(),
          // setting for which theme to use
          ListTile(
            title: Text(
              "Miscellaneous",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18
              ),
            ),
          ),
          ListTile(
              title: Text("theme (used at next app start)"),
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
              onTap: () {}
          ),
          ListTile(
            title: Text("Show tutorials"),
            trailing: IconButton(
              icon: Icon(Icons.replay_outlined),
              onPressed: () { 
                SETTINGS.showShowcaseViewDrawing = true;
                SETTINGS.save();
              }
            )
          ),
        ],
      )
    );
  }
}
