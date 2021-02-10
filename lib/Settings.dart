import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  bool openWithCustomURL;
  bool openWithJisho;
  bool openWithTakoboto;
  bool openWithWadoku;
  String customURL;
  String selectedTheme;
  List<String> themes = ["light", "dark", "system"];
  Map<String, ThemeMode> themesDict = {
    "light" : ThemeMode.light,
    "dark" : ThemeMode.dark,
    "system" : ThemeMode.system
  };

  Settings() {
    setTogglesToFalse();
  }

  void setTogglesToFalse() {
    openWithCustomURL = false;
    openWithJisho = false;
    openWithTakoboto = false;
    openWithWadoku = false;
  }

  void save() async {
    print("saving");

    // obtain shared preferences
    final prefs = await SharedPreferences.getInstance();

    // set value
    prefs.setBool('openWithCustomURL', openWithCustomURL);
    prefs.setBool('openWithJisho', openWithJisho);
    prefs.setBool('openWithTakoboto', openWithTakoboto);
    prefs.setBool('openWithWadoku', openWithWadoku);
    prefs.setString('customURL', customURL);
    prefs.setString('selectedTheme', selectedTheme);
  }

  void load() async {
    print("loading");

    openWithCustomURL = await loadOpenWithCustomURL();
    openWithJisho = await loadOpenWithJisho();
    openWithTakoboto = await loadOpenWithTakoboto();
    openWithWadoku = await loadOpenWithWadoku();
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
