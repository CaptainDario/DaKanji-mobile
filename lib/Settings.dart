import 'package:da_kanji_recognizer_mobile/globals.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  /// The placeholder in the URL's which will be replaced by the predicted kanji
  String kanjiPlaceholder = "%X%";

  /// The custom URL a user can define on the settings page.
  String customURL;

  /// The URL of the jisho website
  String jishoURL;

  /// The URL of the weblio website
  String wadokuURL;

  /// The URL of the weblio website
  String weblioURL;

  /// A list with all available dictionary options.
  List<String> dictionaries = 
    [
      "jisho (web)", 
      "wadoku (web)",
      "weblio (web)",
      "a custom URL",
      "systemTranslator",
      "aedict (app)",
      "akebi (app)",
      "takoboto (app)",
    ];

  /// The string representation of the dictionary which will be used (long press)
  String selectedDictionary;

  // if the showcase view should be shown for the drawing screen
  bool showShowcaseViewDrawing;

  // the application version used when those settings were saved
  String versionUsed;
  
  /// The theme which the application will use.
  /// System will match the settings of the system.
  String selectedTheme;

  /// A list with all available themes.
  List<String> themes = ["light", "dark", "system"];
  

  /// A Map from the string of a theme to the ThemeMode of the theme.
  Map<String, ThemeMode> themesDict = {
    "light": ThemeMode.light,
    "dark": ThemeMode.dark,
    "system": ThemeMode.system
  };

  Settings() {
    String kanjiPlaceholder = "%X%";

    jishoURL = "https://jisho.org/search/" + kanjiPlaceholder;
    wadokuURL = "https://www.wadoku.de/search/" + kanjiPlaceholder;
    weblioURL = "https://www.weblio.jp/content/" + kanjiPlaceholder;
  }

  /// Get the URL to the predicted kanji in the selected dictionary.
  ///
  /// @returns The URL which leads to the predicted kanji in the selected dict.
  String openWithSelectedDictionary(String kanji) {
    String url;

    // determine which URL should be used for finding the character
    if(selectedDictionary == dictionaries[0])
      url = jishoURL;
    else if(selectedDictionary == dictionaries[1])
      url = wadokuURL;
    else if(selectedDictionary == dictionaries[2])
      url = weblioURL;
    else if(selectedDictionary == dictionaries[3])
      url = customURL;

    // check that the URL starts with protocol, otherwise launch() fails
    if (!(url.startsWith("http://") || url.startsWith("https://")))
      url = "https://" + url;

    // replace the placeholder with the actual character
    url = url.replaceFirst(new RegExp(kanjiPlaceholder), kanji);
    url = Uri.encodeFull(url);
    return url;
  }


  /// Saves all settings to the SharedPreferences.
  void save() async {
    // obtain shared preferences
    final prefs = await SharedPreferences.getInstance();

    // set value in shared preferences
    prefs.setBool('showShowcaseViewDrawing', showShowcaseViewDrawing);
    
    prefs.setString('customURL', customURL);
    prefs.setString('selectedTheme', selectedTheme);
    prefs.setString('versionUsed', VERSION);
    prefs.setString('selectedDictionary', selectedDictionary);

  }

  /// Load all saved settings from SharedPreferences.
  void load() async {
    showShowcaseViewDrawing = await loadBool('showShowcaseViewDrawing');

    customURL = await loadString('customURL') ?? "";
    selectedTheme = await loadString('selectedTheme') ?? themes[2];
    versionUsed = await loadString('versionUsed') ?? "";
    selectedDictionary = await loadString('selectedDictionary') ?? dictionaries[0];


    // if different version used than last time -> show tutorial 
    if(versionUsed != VERSION){ 
      showShowcaseViewDrawing = true;
    }
  }

  /// Loads a bool from shared preferences.
  ///
  /// @returns The bool's loaded value of found, otherwise false
  Future<bool> loadBool(String boolName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loaded = prefs.getBool(boolName) ?? false;

    return loaded;
  }

  /// Loads a string value from the shared preferences.
  ///
  /// @returns The string value if found, null otherwise
  Future<String> loadString(String stringName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String loaded = prefs.getString(stringName);

    return loaded;
  }
}

