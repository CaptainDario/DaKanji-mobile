import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'DaKanjiRecognizerDrawer.dart';
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
                  value: value,
                  child: Text(value)
                );
              }).toList(),
              onChanged: (String newValue) {
                setState(() {
                  print(newValue);
                  SETTINGS.selectedDictionary = newValue;
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
                ),
                IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context){ 
                        return SimpleDialog(
                          title: Text("Custom URL format"),
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Text(
                                    "The app will replace a placeholder in the URL with the predicted character. " +
                                    "This placeholder is: " + SETTINGS.kanjiPlaceholder + 
                                    "\n" +
                                    "\n" +
                                    "Example:" +
                                    "\n" +
                                    "The predicted character is: '口'" + 
                                    " and you want to open it on 'jisho.org'. " +
                                    "First you have to get the URL of the website for searching. " + 
                                    "In this case: 'https://jisho.org/search/口'. " + 
                                    "Now only the character in the URL has to be replaced with the placeholder. " + 
                                    "This leads to 'https://jisho.org/search/" + SETTINGS.kanjiPlaceholder + "'."
                                    ),
                                ]
                              )
                            )
                          ],
                        );
                      }
                    );
                  }
                )
              ]
            ),
              onTap: () {}
          ),
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
            title: Text("theme (restarts app)"),
            trailing: DropdownButton<String>(
              value: SETTINGS.selectedTheme,
              items: SETTINGS.themes
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value)
                );
              }).toList(),
              onChanged: (String newValue) {
                setState(() {
                  SETTINGS.selectedTheme = newValue;
                  SETTINGS.save();
                  Phoenix.rebirth(context);
                });
              },
            ),
            onTap: () {}
          ),
          ListTile(
            title: Text("Show tutorial (restarts app)"),
            trailing: IconButton(
              icon: Icon(Icons.replay_outlined),
              onPressed: () { 
                SETTINGS.showShowcaseViewDrawing = true;
                SETTINGS.save();
                Phoenix.rebirth(context);
              }
            )
          ),
        ],
      )
    );
  }
}
