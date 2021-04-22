
import 'package:da_kanji_mobile/PredictionButton.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'globals.dart';



/// This screen opens the given [url]
/// and shows [char] fullscreen while loading.
class WebviewScreen extends StatefulWidget {

  /// the characters which will be searched
  final String char;
  /// the url which will be opened
  final String url;

  WebviewScreen(this.char, this.url);

  @override
  _WebviewScreenState createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen>{

  /// should the webview be shown
  bool loadWebview = false;
  /// should the loading text (predicted character) be hidden
  bool showLoading = true;


  WebView webview;

  @override
  void initState() { 
    super.initState();
  }

  @override
  void dispose() { 
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    // add a listener to when the Navigator animation finished
    var route = ModalRoute.of(context);
    void handler(status) {
      if (status == AnimationStatus.completed) {
        route.animation.removeStatusListener(handler);
        setState(() {
          loadWebview = true;
        });
      }
    }
    route.animation.addStatusListener(handler);
    
    return 
      Scaffold(body: WillPopScope(
        // when leaving this screen hide the webview and  
        onWillPop: () {
          setState(() {
            loadWebview = false;
            showLoading = true;
          });
          return Future.delayed(Duration(milliseconds: 1250), () => true);
        },
        child: Container(
        child: Scaffold(
          appBar: AppBar(
            title: 
            Text(SETTINGS.selectedDictionary + ": " + widget.char),
          ),
          body: Hero(
            tag: "webviewHero_" + widget.char,
            child: () {
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 1000),
                child: () {
                  return Stack(
                    key: ValueKey<String>(showLoading ? "Loading" : "Webview"),
                    children: [
                      // show the webview after it has finished loading
                      if(loadWebview) 
                        WebView(
                          initialUrl: widget.url,
                          onPageFinished: (s) {
                            showLoading = false;
                            setState(() { });
                          }
                        ),
                      // only show predicted character while the webview is loading
                      if(showLoading)
                        Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: Center(
                            child: () {
                              if(widget.char.contains("buffer"))
                                return OutlinedButton(
                                  child: Text(
                                    widget.char,
                                    textScaleFactor: 1.5,
                                    softWrap: false,
                                    style: TextStyle(color: Colors.black, fontSize: 40)
                                  ),
                                  onPressed: () {},
                                );
                              else
                                return PredictionButton(widget.char, () {});
                            } ()
                          )
                        ),
                        
                    ]
                  );
                } (),
                transitionBuilder: (Widget child, Animation<double> animation){
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      child: child,
                      opacity: animation,
                    ),
                  );
                },
              );
            } ()
          )
        )
      )
    ));
  }
}




