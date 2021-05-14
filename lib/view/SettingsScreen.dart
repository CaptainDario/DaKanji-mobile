import 'package:flutter/material.dart';

import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get_it/get_it.dart';

import 'package:da_kanji_mobile/model/core/Screens.dart';
import 'package:da_kanji_mobile/provider/Settings.dart';
import 'package:da_kanji_mobile/view/DaKanjiDrawer.dart';
import 'package:da_kanji_mobile/globals.dart';


/// The "settings"-screen.
/// 
/// Here all settings of the app can be managed.
class SettingsScreen extends StatefulWidget {

  /// was this page opened by clicking on the tab in the drawer
  final bool openedByDrawer;

  SettingsScreen(this.openedByDrawer);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}


class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DaKanjiDrawer(
        currentScreen: Screens.settings,
        animationAtStart: !widget.openedByDrawer,
        // ListView of all available settings
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // different options for dictionary on long press
            ListTile(
              title: Text(
                "Drawing", 
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                ),
              )
            ),
            ListTile(
              title: Text("Long press opens"),
              trailing: DropdownButton<String>(
                value: GetIt.I<Settings>().selectedDictionary,
                items: GetIt.I<Settings>().dictionaries 
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value)
                  );
                }).toList(),
                onChanged: (String newValue) {
                  setState(() {
                    print(newValue);
                    GetIt.I<Settings>().selectedDictionary = newValue;
                    GetIt.I<Settings>().save();
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
                        enabled:
                          GetIt.I<Settings>().selectedDictionary == GetIt.I<Settings>().dictionaries[3],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: GetIt.I<Settings>().customURL,
                          hintText: "URL of your dictionary"), 
                        onChanged: (value) {
                          GetIt.I<Settings>().customURL = value;
                          GetIt.I<Settings>().save();
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
                                      "This placeholder is: " + GetIt.I<Settings>().kanjiPlaceholder + 
                                      "\n" +
                                      "\n" +
                                      "Example:" +
                                      "\n" +
                                      "The predicted character is: '口'" + 
                                      " and you want to open it on 'jisho.org'. " +
                                      "First you have to get the URL of the website for searching. " + 
                                      "In this case: 'https://jisho.org/search/口'. " + 
                                      "Now only the character in the URL has to be replaced with the placeholder. " + 
                                      "This leads to 'https://jisho.org/search/" + GetIt.I<Settings>().kanjiPlaceholder + "'."
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
            // invert if short press or long press opens dict / copies to clip
            CheckboxListTile(
              title: Text("Invert long/short press"),
              value: GetIt.I<Settings>().invertShortLongPress, 
              onChanged: (bool newValue){
                setState(() {
                  GetIt.I<Settings>().invertShortLongPress = newValue;
                  GetIt.I<Settings>().save();
                });
              }
            ),
            // 
            CheckboxListTile(
              title: Text("Empty canvas after double tap"),
              value: GetIt.I<Settings>().emptyCanvasAfterDoubleTap, 
              onChanged: (bool newValue){
                setState(() {
                  GetIt.I<Settings>().emptyCanvasAfterDoubleTap = newValue;
                  GetIt.I<Settings>().save();
                });
              }
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
                value: GetIt.I<Settings>().selectedTheme,
                items: GetIt.I<Settings>().themes
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value)
                  );
                }).toList(),
                onChanged: (String newValue) {
                  setState(() {
                    GetIt.I<Settings>().selectedTheme = newValue;
                    GetIt.I<Settings>().save();
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
                  SHOW_SHOWCASE_DRAWING = true;
                  GetIt.I<Settings>().save();
                  Phoenix.rebirth(context);
                }
              )
            ),
          ],
        )
      )
    );
  }
}
