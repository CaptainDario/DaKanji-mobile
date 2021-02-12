import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  /// The placeholder in the URL's which will be replaced by the predicted kanji
  String kanjiPlaceholder = "%X%";

  /// The custom URL a user can define on the settings page.
  String customURL;
  /// The URL of the jisho website
  String jishoURL;
  /// The URL of the takoboto website
  String takobotoURL;
  /// The URL of the wadoku website
  String wadokuURL;
  /// The URL of the weblio website
  String weblioURL;

  /// Indicates if a long press will use the custom URL.
  bool openWithCustomURL;
  /// Indicates if a long press will use the jisho URL.
  bool openWithJisho;
  /// Indicates if a long press will use the takoboto URL.
  bool openWithTakoboto;
  /// Indicates if a long press will use the wadoku URL.
  bool openWithWadoku;
  /// Indicates if a long press will use the weblio URL.
  bool openWithWeblio;

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
    takobotoURL = "https://http://takoboto.jp/?q=" + kanjiPlaceholder;
    wadokuURL = "https://www.wadoku.de/search/" + kanjiPlaceholder;
    weblioURL = "https://www.weblio.jp/content/" + kanjiPlaceholder;
  }

  /// Get the URL to the predicted kanji in the selected dictionary.
  /// 
  /// @returns The URL which leads to the predicted kanji in the selected dict. 
  String openWithSelectedDictionary(String kanji) {
    String url;

    if (openWithCustomURL)
      url = customURL;
    else if (openWithJisho)
      url = jishoURL;
    else if (openWithTakoboto)
      url = takobotoURL;
    else if (openWithWadoku)
      url = wadokuURL;
    else if (openWithWeblio) url = weblioURL;

    return url = url.replaceFirst(new RegExp(kanjiPlaceholder), kanji);
  }

  /// Set all values of the toggles in the Settings menu to false. 
  void setTogglesToFalse() {
    openWithCustomURL = false;
    openWithJisho = false;
    openWithTakoboto = false;
    openWithWadoku = false;
    openWithWeblio = false;
  }

  /// Saves all settings to the SharedPreferences.
  void save() async {
    print("saving");

    // obtain shared preferences
    final prefs = await SharedPreferences.getInstance();

    // set value
    prefs.setBool('openWithCustomURL', openWithCustomURL);
    prefs.setBool('openWithJisho', openWithJisho);
    prefs.setBool('openWithTakoboto', openWithTakoboto);
    prefs.setBool('openWithWadoku', openWithWadoku);
    prefs.setBool('openWithWeblio', openWithWeblio);
    prefs.setString('customURL', customURL);
    prefs.setString('selectedTheme', selectedTheme);
  }

  /// Load all saved settings from SharedPreferences.
  void load() async {
    print("loading");

    openWithCustomURL = await loadOpenWithCustomURL();
    openWithJisho = await loadOpenWithJisho();
    openWithTakoboto = await loadOpenWithTakoboto();
    openWithWadoku = await loadOpenWithWadoku();
    openWithWeblio = await loadOpenWithWeblio();
    customURL = await loadCustomURL();
    selectedTheme = await loadSelectedTheme();

    // assure that atleast one switch is set to true
    if (!this.openWithCustomURL &&
        !this.openWithJisho &&
        !this.openWithTakoboto &&
        !this.openWithWadoku) {
      this.openWithJisho = true;
    }
  }

  Future<bool> loadOpenWithCustomURL() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loaded = prefs.getBool('openWithCustomURL') ?? false;

    return loaded;
  }

  Future<bool> loadOpenWithJisho() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loaded = prefs.getBool('openWithJisho') ?? false;

    return loaded;
  }

  Future<bool> loadOpenWithTakoboto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loaded = prefs.getBool('openWithTakoboto') ?? false;

    return loaded;
  }

  Future<bool> loadOpenWithWadoku() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loaded = prefs.getBool('openWithWadoku') ?? false;

    return loaded;
  }

  Future<bool> loadOpenWithWeblio() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loaded = prefs.getBool("openWithWeblio") ?? false;

    return loaded;
  }

  Future<String> loadCustomURL() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String loaded = prefs.getString('customURL') ?? "";

    return loaded;
  }

  Future<String> loadSelectedTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String loaded = prefs.getString('selectedTheme') ?? "system";

    return loaded;
  }
}
