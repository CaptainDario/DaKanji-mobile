import 'dart:math';
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

class _WebviewScreenState extends State<WebviewScreen>
  with TickerProviderStateMixin{

  /// should the webview be shown
  bool loadWebview;

  /// 
  bool showLoading;

  double width;


  int switchAnimationTime;

  int leaveTime;

  AnimationController _controller;

  Animation _rotationAnimation;


  WebView webview;

  @override
  void initState() { 
    super.initState();

    loadWebview = false;
    showLoading = false;

    switchAnimationTime = 500;
    leaveTime = switchAnimationTime + 250;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _rotationAnimation = new Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(new CurvedAnimation(
      parent: _controller,
      curve: Interval(
        0.0, 1.00,
        curve: Curves.linear
      ),
    ));
    _controller.addListener(() {setState(() {});});
    
  }

  @override
  void dispose() { 
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context){

    width = MediaQuery.of(context).size.width;

    // add a listener to when the screen change animation finished
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
    
    return Scaffold(
      appBar: AppBar(
        title: 
        Text(SETTINGS.selectedDictionary + ": " + widget.char),
      ),
      body: WillPopScope(
        // when leaving this screen hide the webview and  
        onWillPop: () {
          setState(() {
            showLoading = false;
            _controller.reverse();
          });
          return Future.delayed(Duration(milliseconds: leaveTime), () => true);
        },
        child: Container(
          child: 
            Stack(
              children: [
                Transform.translate(
                  offset: Offset(
                    (width) * (1 - _rotationAnimation.value), 
                    0
                  ),
                  child: Transform(
                    transform: new Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..multiply(Matrix4.rotationY(
                        (_rotationAnimation.value - 1) * (pi/2))
                      ),
                    alignment: Alignment.centerLeft,
                    child: () {
                        if(loadWebview){
                          return WebView(
                            initialUrl: widget.url,
                            onPageFinished: (s) {
                              _controller.forward(from: 0.0);
                            }
                          );
                        }
                        else
                          return Container(color: Colors.green,);
                    } ()
                  )
                ),
                
                // only show predicted character while the webview is loading
                Transform.translate(
                  offset: Offset(
                    (width) * (1 - _rotationAnimation.value) - width,
                    0
                  ),
                  child: Transform(
                    transform: new Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..multiply(Matrix4.rotationY(
                        _rotationAnimation.value * pi/2
                      )),
                    alignment: Alignment.centerRight,
                    child: Hero(
                      tag: "webviewHero_" + widget.char,
                      child: Container(
                        child: Center(
                          child: Text(
                            widget.char,
                            style: TextStyle(
                              color: Theme.of(context).textTheme.button.color,
                              decoration: TextDecoration.none,
                              fontSize: 60,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        )
                      )
                    )
                  )
                )
              ]
            ),
          )
        )
      //)
    );
  }
}




