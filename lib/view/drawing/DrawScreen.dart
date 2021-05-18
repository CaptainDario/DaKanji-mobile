import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get_it/get_it.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

import 'package:da_kanji_mobile/model/core/Screens.dart';
import 'package:da_kanji_mobile/model/core/DrawingInterpreter.dart';
import 'package:da_kanji_mobile/view/drawing/DrawScreenShowcase.dart';
import 'package:da_kanji_mobile/provider/KanjiBuffer.dart';
import 'package:da_kanji_mobile/provider/Strokes.dart';
import 'package:da_kanji_mobile/view/DaKanjiDrawer.dart';
import 'package:da_kanji_mobile/view/drawing//PredictionButton.dart';
import 'package:da_kanji_mobile/view/drawing/KanjiBufferWidget.dart';
import 'package:da_kanji_mobile/view/drawing/DrawingCanvas.dart';
import 'package:da_kanji_mobile/globals.dart';


/// The "draw"-screen.
/// 
/// Lets the user draw a kanji and than shows the most likely predictions.
/// Those can than be copied / opened in dictionaries by buttons.
class DrawScreen extends StatefulWidget
  with GetItStatefulWidgetMixin {

  // init the tutorial of the draw screen
  final showcase = DrawScreenShowcase();
  /// was this page opened by clicking on the tab in the drawer
  final bool openedByDrawer;

  DrawScreen(this.openedByDrawer);

  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen>
  with TickerProviderStateMixin, GetItStateMixin{
  /// the size of the canvas widget
  double _canvasSize;

  @override
  void initState() {
    super.initState();

    // initialize the drawing interpreter
    GetIt.I<DrawingInterpreter>().init();

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = (Theme.of(context).brightness == Brightness.dark);
    // init size of canvas and assure that it is min. 20 smaller than screen width
    _canvasSize = MediaQuery.of(context).size.height * 3/6;
    if(_canvasSize >= MediaQuery.of(context).size.width - 20)
      _canvasSize = MediaQuery.of(context).size.width - 20;
    
    // add a listener to when the Navigator animation finished
    var route = ModalRoute.of(context);
    void handler(status) {
      if (status == AnimationStatus.completed) {
        route.animation.removeStatusListener(handler);
        
        if(SHOW_SHOWCASE_DRAWING){
          widget.showcase.init(context);
          widget.showcase.show();
        }
      }
    }
    route.animation.addStatusListener(handler);

    // GetItMixin watchers
    final List<String> predictions =
      watchOnly((DrawingInterpreter d) => d.predictions);
    final Strokes strokes = watchOnly((Strokes s) => s);
    final String kanjiBuffer = watchOnly((KanjiBuffer k) => k.kanjiBuffer);


    return DaKanjiDrawer(
      currentScreen: Screens.drawing,
      animationAtStart: !widget.openedByDrawer,
      child: Center(
        child: Column( 
          children: [
            // the canvas to draw on
            DrawingCanvas(
              width: _canvasSize, 
              height: _canvasSize,
              margin: EdgeInsets.fromLTRB(0, 
                (MediaQuery.of(context).size.width - _canvasSize) / 2, 
                0, 0),
              key: SHOWCASE_DRAWING[0].key,
              strokes: strokes,
            ),
            Spacer(),
            // undo/clear button and kanjiBuffer,
            Container(
              width: _canvasSize,
              child: Row(
                children: [
                  // undo
                  IconButton(
                    key: SHOWCASE_DRAWING[1].key,
                    icon: Icon(Icons.undo),
                    onPressed: () {
                      strokes.deleteLastStrokeAnimation();
                      setState(() {});
                    }
                  ),
                  // multi character search input
                    Expanded(
                    child: Hero(
                      tag: "webviewHero_b_" + 
                        (kanjiBuffer == "" ? "Buffer" : kanjiBuffer),
                      child: Center(
                        key: SHOWCASE_DRAWING[6].key,
                        child: KanjiBufferWidget(_canvasSize)
                      )
                    ),
                  ),
                  // clear
                  IconButton(
                    key: SHOWCASE_DRAWING[2].key,
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      strokes.deleteAllStrokesAnimation();
                      setState((){});
                    }
                  ), 
                ]
              ),
            ),
            // prediction buttons
            Container(
              key: SHOWCASE_DRAWING[3].key,
              width: _canvasSize,
              // approximated button height (width/5) * numRows + padding  
              height: (_canvasSize / 5.0) * 2.0 + 10, 
              child: GridView.count(
                physics: new NeverScrollableScrollPhysics(),
                crossAxisCount: 5,
                children: List.generate(10, (i) {
                  Widget widget = PredictionButton(predictions[i]);
                  // instantiate short/long press showcase button
                  if(i == 0){
                    widget = Container(
                      key: SHOWCASE_DRAWING[4].key,
                      child: widget 
                    );
                  }
                  return Hero(
                    tag: "webviewHero_" + 
                      (predictions[i] == " " ? i.toString() : predictions[i]),
                    child: widget,
                  );
                },
                )
              )
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
