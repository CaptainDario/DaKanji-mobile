import 'package:flutter/material.dart';

import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:da_kanji_mobile/model/core/Screens.dart';
import 'package:da_kanji_mobile/provider/Settings.dart';
import 'package:da_kanji_mobile/view/DaKanjiDrawer.dart';
import 'package:da_kanji_mobile/globals.dart';
import 'package:da_kanji_mobile/locales_keys.dart';


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
                      LocaleKeys.SettingsScreen_drawing_title.tr(), 
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                      ),
                    )
                  ),
                  // dictionary selection
                  ListTile(
                    title: Text(LocaleKeys.SettingsScreen_long_press_opens.tr()),
                    trailing: DropdownButton<String>(
                        value: GetIt.I<Settings>().selectedDictionary,
                        items: GetIt.I<Settings>().dictionaries 
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: () {
                              String text = value.replaceAll("url", LocaleKeys.custom_url.tr());
                              text = text.replaceAll("app", LocaleKeys.app.tr());
                              text = text.replaceAll("web", LocaleKeys.web.tr());
                              
                              return Text(text);
                            } ()
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
                                hintText: LocaleKeys.SettingsScreen_custom_url_hint.tr()), 
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
                                    LocaleKeys.SettingsScreen_custom_url_format.tr(),
                                    textScaleFactor: 2,
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Text(
                                          LocaleKeys.SettingsScreen_custom_url_explanation.tr(
                                            namedArgs: {'kanjiPlaceholder' : 
                                              GetIt.I<Settings>().kanjiPlaceholder}
                                          )
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
                    title: Text(LocaleKeys.SettingsScreen_invert_short_long_press.tr()),
                    value: GetIt.I<Settings>().invertShortLongPress, 
                    onChanged: (bool newValue){
                      settings.invertShortLongPress = newValue;
                      settings.save();
                    }
                  ),
                  // should a double tap on a prediction button empty the canvas
                  CheckboxListTile(
                    title: Text(LocaleKeys.SettingsScreen_empty_canvas_after_double_tap.tr()),
                    value: GetIt.I<Settings>().emptyCanvasAfterDoubleTap, 
                    onChanged: (bool newValue){
                      settings.emptyCanvasAfterDoubleTap = newValue;
                      settings.save();
                    }
                  ),
                  CheckboxListTile(
                    title: Text(LocaleKeys.SettingsScreen_use_default_browser_for_online_dictionaries.tr()),
                    value: GetIt.I<Settings>().useDefaultBrowser, 
                    onChanged: (bool newValue){
                      settings.useDefaultBrowser = newValue;
                      settings.save();
                    }
                  ),

                  Divider(),
                  // miscellaneous header
                  ListTile(
                    title: Text(
                      LocaleKeys.SettingsScreen_miscellaneous_title.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                      ),
                    ),
                  ),
                  // setting for which theme to use
                  ListTile(
                    title: Text(LocaleKeys.SettingsScreen_theme.tr()),
                    trailing: DropdownButton<String>(
                      value: GetIt.I<Settings>().selectedTheme,
                      items: GetIt.I<Settings>().themes
                        .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: () {
                            String text = value.replaceAll("light", LocaleKeys.light.tr());
                            text = text.replaceAll("dark", LocaleKeys.dark.tr());
                            text = text.replaceAll("system", LocaleKeys.system.tr());
                            
                            return Text(text);
                          } ()
                          );
                        }
                      ).toList(),
                      onChanged: (String newValue) {
                        settings.selectedTheme = newValue;
                        settings.save();
                        Phoenix.rebirth(context);
                      },
                    ),
                    onTap: () {}
                  ),
                  // TODO :setting for which language to use

                  // reshow tutorial
                  ListTile(
                    title: Text(LocaleKeys.SettingsScreen_show_tutorial.tr()),
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
