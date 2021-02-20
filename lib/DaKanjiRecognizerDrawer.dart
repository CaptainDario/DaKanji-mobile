import 'package:flutter/material.dart';

import 'globals.dart';


class DaKanjiRecognizerDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    // create an drawer style application
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(child: Text("DaKanjiRecognizer")),
          
          // Drawer entry to go to the Kanji drawing screen
          ListTile(
            leading: Icon(Icons.brush_outlined),
            title: Text("Drawing"),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, "/", (Route<dynamic> route) => false);
            },
          ),

          // Drawer entry to go to the settings screen
          ListTile(
            key: SHOWCASE_KEYS_DRAWING[6],
            leading: Icon(Icons.settings_applications),
            title: Text("Settings"),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, "/settings", (Route<dynamic> route) => false);
            },
          ),

          // Drawer entry to go to the about screen
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("About"),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, "/about", (Route<dynamic> route) => false);
            },
          ),
        ],
      )
    );
  }
}
