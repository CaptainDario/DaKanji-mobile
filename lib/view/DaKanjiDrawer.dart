import 'dart:ui';

import 'package:flutter/material.dart';

import '../globals.dart';


/// Da Kanji's drawer.
/// 
/// It connects the main screens of the app with each other.
/// Currently: *Drawing*, *Settings*, *About*
class DaKanjiDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    // create an drawer style application
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).padding.top + 64 + 20,
            child: DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Image( height: 84, image: AssetImage("media/banner.png"),),
                ]
              ),
              margin: EdgeInsets.all(0),
              padding: EdgeInsets.all(0),
            ),
          ),

          // Drawer entry to go to the Kanji drawing screen
          ListTile(
            leading: Icon(Icons.brush_outlined),
            title: Text("Drawing"),
            onTap: () {
              print(ModalRoute.of(context).settings.name);
              if(ModalRoute.of(context).settings.name != "/drawing"){
                Navigator.pushNamedAndRemoveUntil(
                  context, "/drawing", (Route<dynamic> route) => false);
              }
            },
          ),

          // Drawer entry to go to the settings screen
          ListTile(
            key: SHOWCASE_DRAWING[12].key,
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
