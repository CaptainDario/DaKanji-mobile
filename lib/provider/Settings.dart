import 'package:da_kanji_mobile/globals.dart';
import 'package:da_kanji_mobile/provider/Changelog.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings with ChangeNotifier {
  /// The placeholder in the URL's which will be replaced by the predicted kanji
  String kanjiPlaceholder;

  /// The custom URL a user can define on the settings page.
  String customURL;

  /// The URL of the jisho website
  String jishoURL;

  /// The URL of the weblio website
  String wadokuURL;

  /// The URL of the weblio website
  String weblioURL;

  /// A list with all available dictionary options.
  List<String> dictionaries;

  /// The string representation of the dictionary which will be used (long press)
  String _selectedDictionary;

  // the application version used when this settings object was saved
  String versionUsed;
  
  /// The theme which the application will use.
  /// System will match the settings of the system.
  String _selectedTheme;

  /// A list with all available themes.
  List<String> themes;
  
  /// A Map from the string of a theme to the ThemeMode of the theme.
  Map<String, ThemeMode> themesDict;

  /// Should the behavior of long and short press be inverted
  bool _invertShortLongPress;

  /// Should the canvas be cleared when a prediction was copied to kanjibuffer
  bool _emptyCanvasAfterDoubleTap;

  bool _useDefaultBrowser;


  Settings(){
    kanjiPlaceholder = "%X%";

    dictionaries = [
      "jisho (web)", 
      "wadoku (web)",
      "weblio (web)",
      "a custom URL",
      "systemTranslator",
      "aedict (app)",
      "akebi (app)",
      "takoboto (app)",
    ];

    themes = ["light", "dark", "system"];

    themesDict = {
      "light": ThemeMode.light,
      "dark": ThemeMode.dark,
      "system": ThemeMode.system
    };

    invertShortLongPress = false;
    emptyCanvasAfterDoubleTap = true;
    useDefaultBrowser = true;

    jishoURL = "https://jisho.org/search/" + kanjiPlaceholder;
    wadokuURL = "https://www.wadoku.de/search/" + kanjiPlaceholder;
    weblioURL = "https://www.weblio.jp/content/" + kanjiPlaceholder;
  }

  String get selectedDictionary{
    return _selectedDictionary;
  }

  set selectedDictionary(String newDictionary){
    _selectedDictionary = newDictionary;
    notifyListeners();
  }

  get selectedTheme{
    return _selectedTheme;
  }

  ThemeMode selectedThemeMode() {
    return themesDict[_selectedTheme];
  }
  
  set selectedTheme(String newTheme){
    _selectedTheme = newTheme;
    notifyListeners();
  }
  
  bool get invertShortLongPress{
    return _invertShortLongPress;
  }

  set invertShortLongPress(bool invert){
    _invertShortLongPress = invert;
    notifyListeners();
  }

  bool get emptyCanvasAfterDoubleTap{
    return _emptyCanvasAfterDoubleTap;
  }
  
  set emptyCanvasAfterDoubleTap(bool empty){
    _emptyCanvasAfterDoubleTap = empty;
    notifyListeners();
  }
  
  bool get useDefaultBrowser{
    return _useDefaultBrowser;
  }
  
  set useDefaultBrowser(bool empty){
    _useDefaultBrowser = empty;
    notifyListeners();
  }

  /// Saves all settings to the SharedPreferences.
  void save() async {
    // obtain shared preferences
    final prefs = await SharedPreferences.getInstance();

    // set value in shared preferences
    prefs.setBool('invertShortLongPress', invertShortLongPress);
    prefs.setBool('emptyCanvasAfterDoubleTap', emptyCanvasAfterDoubleTap);
    prefs.setBool('useDefaultBrowser', useDefaultBrowser);
    
    prefs.setString('customURL', customURL);
    prefs.setString('selectedTheme', _selectedTheme);
    prefs.setString('versionUsed', VERSION);
    prefs.setString('selectedDictionary', selectedDictionary);
  }

  /// Load all saved settings from SharedPreferences.
  void load() async {
    invertShortLongPress = await loadBool('invertShortLongPress');
    emptyCanvasAfterDoubleTap = await loadBool('emptyCanvasAfterDoubleTap');
    useDefaultBrowser = await loadBool('useDefaultBrowser');

    customURL = await loadString('customURL') ?? '';
    _selectedTheme = await loadString('selectedTheme') ?? themes[2];
    versionUsed = await loadString('versionUsed') ?? '';
    selectedDictionary = await loadString('selectedDictionary') ?? dictionaries[0];

    // a different version than last time is being used
    //VERSION = "0.0.0";
    if(versionUsed != VERSION){

      // show the changelog
      GetIt.I<Changelog>().showChangelog = true;

      // this version has new features for drawing screen => show tutorial
      if(DRAWING_SCREEN_NEW_FEATURES.contains(VERSION)){
        SHOW_SHOWCASE_DRAWING = true;
      }
    }
  }

  /// Loads a bool from shared preferences.
  ///
  /// @returns The bool's loaded value if found, otherwise false
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

