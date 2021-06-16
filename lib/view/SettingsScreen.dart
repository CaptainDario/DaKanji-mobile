import 'package:flutter/material.dart';

import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

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
        child: ChangeNotifierProvider.value(
          value: GetIt.I<Settings>(),
          child: Consumer<Settings>(
            builder: (context, settings, child){
              return ListView(
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
                          settings.selectedDictionary = newValue;
                          settings.save();
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
                                settings.customURL = value;
                                settings.save();
                              },
                            )
                          )
                        ),
                        IconButton(
                          icon: Icon(Icons.info_outline),
                          onPressed: () {
                            AwesomeDialog(
                              context: context,
                              animType: AnimType.SCALE,
                              dialogType: DialogType.INFO,
                              headerAnimationLoop: false,
                              body: Column(
                                children: [
                                  Text(
                                    "Custom URL format",
                                    textScaleFactor: 2,
                                  ),
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
                                  ),
                                ],
                              ),
                            )..show();
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
                      settings.invertShortLongPress = newValue;
                      settings.save();
                    }
                  ),
                  // should a double tap on a prediction button empty the canvas
                  CheckboxListTile(
                    title: Text("Empty canvas after double tap"),
                    value: GetIt.I<Settings>().emptyCanvasAfterDoubleTap, 
                    onChanged: (bool newValue){
                      settings.emptyCanvasAfterDoubleTap = newValue;
                      settings.save();
                    }
                  ),
                  CheckboxListTile(
                    title: Text("Use default browser for online dictionaries"),
                    value: GetIt.I<Settings>().useDefaultBrowser, 
                    onChanged: (bool newValue){
                      settings.useDefaultBrowser = newValue;
                      settings.save();
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
                        settings.selectedTheme = newValue;
                        settings.save();
                        Phoenix.rebirth(context);
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
              );
            },
          ),
        )
      )
    );
  }
}
