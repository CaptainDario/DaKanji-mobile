import 'package:flutter/material.dart';

import 'SettingsScreen.dart';

class DaKanjiRecognizerDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(child: Text("DaKanjiRecognizer")),
        ListTile(
          leading: Icon(Icons.brush_outlined),
          title: Text("Drawing"),
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(
                context, "/", (Route<dynamic> route) => false);
          },
        ),
        ListTile(
          leading: Icon(Icons.settings_applications),
          title: Text("Settings"),
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(
                context, "/settings", (Route<dynamic> route) => false);
          },
        ),
        ListTile(
          leading: Icon(Icons.info_outline),
          title: Text("About"),
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(
                context, "/about", (Route<dynamic> route) => false);
          },
        ),
      ],
    ));
  }
}
