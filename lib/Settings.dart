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

  /// Indicates if a long press will use the custom URL.
  bool openWithCustomURL;

  /// Indicates if a long press will use the jisho URL.
  bool openWithJisho;

  /// Indicates if a long press will use the wadoku URL.
  bool openWithWadoku;

  /// Indicates if a long press will use the weblio URL.
  bool openWithWeblio;
  
  /// Indicates if a long press will use the default translator.
  bool openWithDefaultTranslator;

  /// A list with all available dictionary options.
  List<String> dictionaries = 
    ["a custom URL", "systemTranslator", "jisho.org", "wadoku.de", "weblio.jp"];

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
    setTogglesToFalse();

    String kanjiPlaceholder = "%X%";

    jishoURL = "https://jisho.org/search/" + kanjiPlaceholder + "%23kanji";
    wadokuURL = "https://www.wadoku.de/search/" + kanjiPlaceholder;
    weblioURL = "https://www.weblio.jp/content/" + kanjiPlaceholder;
  }

  /// Get the URL to the predicted kanji in the selected dictionary.
  ///
  /// @returns The URL which leads to the predicted kanji in the selected dict.
  String openWithSelectedDictionary(String kanji) {
    String url;

    // determine which URL should be used for finding the character
    if (openWithCustomURL)
      url = customURL;
    else if (openWithJisho)
      url = jishoURL;
    else if (openWithWadoku)
      url = wadokuURL;
    else if (openWithWeblio)
      url = weblioURL;

    // check that the URL starts with protocol, otherwise launch(fails)
    if (!(url.startsWith("http://") || url.startsWith("https://")))
      url = "https://" + url;

    // replace the placeholder with the actual character
    url = url.replaceFirst(new RegExp(kanjiPlaceholder), kanji);
    url = Uri.encodeFull(url);
    return url;
  }

  /// Set all values of the dictionary toggles in the Settings menu to false.
  void setTogglesToFalse() {
    openWithCustomURL = false;
    openWithJisho = false;
    openWithWadoku = false;
    openWithWeblio = false;
    openWithDefaultTranslator = false;
  }

  /// Set the bool of the dictionary which currently being used from string
  /// 
  /// @params the string of the currently selected dictionary
  void setDictionary(String selection){

    setTogglesToFalse();
    selectedDictionary = selection;

    if(selection == dictionaries[0])
      openWithCustomURL = true;
    else if(selection == dictionaries[1])
      openWithDefaultTranslator = true;
    else if(selection == dictionaries[2])
      openWithJisho = true;
    else if(selection == dictionaries[3])
      openWithWadoku = true;
    else if(selection == dictionaries[4])
      openWithWeblio = true;
    else
      print("dictionary undefined");

  }

  /// Saves all settings to the SharedPreferences.
  void save() async {
    // obtain shared preferences
    final prefs = await SharedPreferences.getInstance();

    // set value in shared preferences
    prefs.setBool('openWithCustomURL', openWithCustomURL);
    prefs.setBool('openWithJisho', openWithJisho);
    prefs.setBool('openWithDefaultTranslator', openWithDefaultTranslator);
    prefs.setBool('openWithWadoku', openWithWadoku);
    prefs.setBool('openWithWeblio', openWithWeblio);
    prefs.setBool('showShowcaseViewDrawing', showShowcaseViewDrawing);
    
    prefs.setString('customURL', customURL);
    prefs.setString('selectedTheme', selectedTheme);
    prefs.setString('versionUsed', VERSION);
    prefs.setString('selectedDictionary', selectedDictionary);

    // make sure the loaded drop down values are correct
    if(selectedDictionary == "") selectedDictionary = "jisho.org";
    if(selectedTheme == "") selectedTheme = themes[0];
  }

  /// Load all saved settings from SharedPreferences.
  void load() async {
    openWithCustomURL = await loadBool('openWithCustomURL');
    openWithJisho = await loadBool('openWithJisho');
    openWithDefaultTranslator = await loadBool('openWithDefaultTranslator');
    openWithWadoku = await loadBool('openWithWadoku');
    openWithWeblio = await loadBool('openWithWeblio');
    showShowcaseViewDrawing = await loadBool('showShowcaseViewDrawing');

    customURL = await loadString('customURL') ?? "";
    selectedTheme = await loadString('selectedTheme') ?? themes[2];
    versionUsed = await loadString('versionUsed') ?? "";
    selectedDictionary = await loadString('selectedDictionary') ?? dictionaries[2];

    // assure that at least one switch is set to true
    if (!this.openWithCustomURL &&
        !this.openWithJisho &&
        !this.openWithDefaultTranslator &&
        !this.openWithWadoku &&
        !this.openWithWeblio) {
      this.openWithJisho = true;
    }

    // if another version used than last time -> show showcase
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

