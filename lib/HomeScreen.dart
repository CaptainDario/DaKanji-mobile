import 'package:da_kanji_recognizer_mobile/DrawScreen.dart';
import 'package:da_kanji_recognizer_mobile/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';



class HomeScreen extends StatefulWidget {

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() { 
    super.initState();

    // after the page was build open the what's new pop up
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(SHOW_CHANGELOG){
        SHOW_CHANGELOG = false;
    
        showDialog(
          context: context,
          builder: (BuildContext context){ 
            return SimpleDialog(
              title: Center(child: Text("🎉 What's new 🎉")),
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      SizedBox(
                        child: Markdown(data: NEW_CHANGELOG,),
                        width: MediaQuery.of(context).size.width * 3/4,
                        height: MediaQuery.of(context).size.height * 2/4,
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: 
                            MaterialStateProperty.all(
                              Color.fromARGB(100, 150, 150, 150)
                            )
                        ),
                        onPressed: () async {
                          SETTINGS.save();
                          Navigator.pushNamedAndRemoveUntil(
                            context, "/home", (Route<dynamic> route) => false);
                        },
                        child: Text("close")
                      )
                    ]
                  )
                )
              ],
            );
          }
        ).then((value) {
          SETTINGS.save();
          Navigator.pushNamedAndRemoveUntil(
            context, "/home", (Route<dynamic> route) => false);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    // show changelog pop up when a new version is being used
    if(SHOW_CHANGELOG){
      return Scaffold();
    }
    // otherwise show the drawing screen
    else{
      return DrawScreen();
    }
  }
}
