import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

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
class DrawScreen extends StatefulWidget {

  // init the tutorial of the draw screen
  final showcase = DrawScreenShowcase();
  /// was this page opened by clicking on the tab in the drawer
  final bool openedByDrawer;

  DrawScreen(this.openedByDrawer);

  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> with TickerProviderStateMixin {
  /// the size of the canvas widget
  double _canvasSize;
  /// the minimum padding around the drawing canvas (left, top, right)
  double _canvasPad = 10.0;

  @override
  void initState() {
    super.initState();

    if(!GetIt.I<DrawingInterpreter>().wasInitialized){
      // initialize the drawing interpreter
      GetIt.I<DrawingInterpreter>().init();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
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


    return DaKanjiDrawer(
      currentScreen: Screens.drawing,
      animationAtStart: !widget.openedByDrawer,
      child: Center(
        child: ChangeNotifierProvider.value(
          value: GetIt.I<Strokes>(),
          // create responsive layouts
          child: LayoutBuilder(
            builder: (context, constraints){
              // init size of canvas
              // and assure that it is min. 20 smaller than screen width
              _canvasSize = constraints.biggest.height * 3/6;
              if(_canvasSize >= constraints.biggest.width - _canvasPad)
                _canvasSize = constraints.biggest.height - _canvasPad;
              
              return Column( 
                children: [
                  // the canvas to draw on
                  Consumer<Strokes>(
                    builder: (context, strokes, __){
                      return DrawingCanvas(
                        width: _canvasSize, 
                        height: _canvasSize,
                        margin: EdgeInsets.fromLTRB(0, _canvasPad, 0, 0),
                        key: SHOWCASE_DRAWING[0].key,
                        strokes: strokes,
            
                        onFinishedDrawing: (Uint8List image) async {
                          GetIt.I<DrawingInterpreter>().runInference(image);
                        },
                        onDeletedLastStroke: (Uint8List image) {
                          if(strokes.strokeCount > 0)
                            GetIt.I<DrawingInterpreter>().runInference(image);
                          else
                            GetIt.I<DrawingInterpreter>().clearPredictions();
                        },
                        onDeletedAllStrokes: () {
                          GetIt.I<DrawingInterpreter>().clearPredictions();
                        },
                      );
                    },
                  ),
                  Container(
                    height: constraints.biggest.height * 1/6,
                    child:
                    // undo/clear button and kanjiBuffer,
                      Container(
                        width: _canvasSize,
                        child: Row(
                          children: [
                            // undo
                            Consumer<Strokes>(
                              builder: (context, strokes, __) {
                                return IconButton(
                                  key: SHOWCASE_DRAWING[1].key,
                                  icon: Icon(Icons.undo),
                                  onPressed: () {
                                    strokes.playDeleteLastStrokeAnimation = true;
                                  }
                                );
                              }
                            ),
                            // multi character search input
                            ChangeNotifierProvider.value(
                              value: GetIt.I<KanjiBuffer>(),
                              child: Expanded(
                                child: Consumer<KanjiBuffer>(
                                  builder: (context, kanjiBuffer, child){
                                    return Hero(
                                    tag: "webviewHero_b_" + 
                                      (kanjiBuffer.kanjiBuffer == "" 
                                        ? "Buffer" : kanjiBuffer.kanjiBuffer),
                                      child: Center(
                                        key: SHOWCASE_DRAWING[6].key,
                                        child: KanjiBufferWidget(_canvasSize)
                                      )
                                    );
                                  }
                                ),
                              ),
                            ),
                            // clear
                            Consumer<Strokes>(
                              builder: (contxt, strokes, _) {
                                return  IconButton(
                                  key: SHOWCASE_DRAWING[2].key,
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    strokes.playDeleteAllStrokesAnimation = true;
                                  }
                                );
                              }
                            ), 
                          ]
                        ),
                      ),
                  ),
                  // prediction buttons
                  Container(
                    key: SHOWCASE_DRAWING[3].key,
                    width: _canvasSize,
                    // approximated button height (width/5) * numRows + padding  
                    height: (_canvasSize / 5.0) * 2.0 + 10, 
                    child: ChangeNotifierProvider.value(
                      value: GetIt.I<DrawingInterpreter>(),
                      child: Consumer<DrawingInterpreter>(
                        builder: (context, interpreter, child){
                          return GridView.count(
                            physics: new NeverScrollableScrollPhysics(),
                            crossAxisCount: 5,
                            children: List.generate(10, (i) {
                              Widget widget =
                                PredictionButton(interpreter.predictions[i]);
                              // instantiate short/long press showcase button
                              if(i == 0){
                                widget = Container(
                                  key: SHOWCASE_DRAWING[4].key,
                                  child: widget 
                                );
                              }
                              return Hero(
                                tag: "webviewHero_" + 
                                  (interpreter.predictions[i] == " " 
                                    ? i.toString() : interpreter.predictions[i]),
                                child: widget,
                              );
                            },
                            )
                          );
                        }
                      ),
                    )
                  ),
                  Spacer(),
                ],
              );
            }
          ),
        ),
      ),
    );
  }
}
