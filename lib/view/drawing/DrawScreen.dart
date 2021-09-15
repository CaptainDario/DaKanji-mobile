import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

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
      child: ChangeNotifierProvider.value(
        value: GetIt.I<Strokes>(),
        child: LayoutBuilder(
          builder: (context, constraints){
            bool landscape;
            // init size of canvas
            //landscape
            if(constraints.biggest.width > constraints.biggest.height){
              _canvasSize = constraints.biggest.height * 0.80;
              landscape = true;
              if(_canvasSize >= constraints.biggest.height)
                _canvasSize = constraints.biggest.width;
            }
            // portrait
            if(constraints.biggest.width < constraints.biggest.height){
              _canvasSize = constraints.biggest.width - 10;
              landscape = false;
              if(_canvasSize >= constraints.biggest.width)
                _canvasSize = constraints.biggest.height;
            }
            

            // the canvas to draw on
            Widget drawingCanvas = Consumer<Strokes>(
              builder: (context, strokes, __){
                return DrawingCanvas(
                  width: _canvasSize, 
                  height: _canvasSize,
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
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
            );
            // undo
            Widget undoButton = Consumer<Strokes>(
              builder: (context, strokes, __) {
                return Center(
                  child: IconButton(
                    key: SHOWCASE_DRAWING[1].key,
                    icon: Icon(Icons.undo),
                    iconSize: 20,
                    onPressed: () {
                      strokes.playDeleteLastStrokeAnimation = true;
                    }
                  ),
                );
              }
            );
            // multi character search input
            Widget multiCharSearch = ChangeNotifierProvider.value(
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
            );
            // clear
            Widget clearButton = Consumer<Strokes>(
              builder: (contxt, strokes, _) {
                return Center(
                  child: IconButton(
                    key: SHOWCASE_DRAWING[2].key,
                    icon: Icon(Icons.clear),
                    iconSize: 20,
                    onPressed: () {
                      strokes.playDeleteAllStrokesAnimation = true;
                    }
                  ),
                );
              }
            );
            // prediction buttons
            Widget predictionButtons = Container(
              key: SHOWCASE_DRAWING[3].key,
              //color: Colors.green,
              // (constraints.biggest.height / 5.0 * 2.0) 
              // use full height in landscape
              //width :  landscape ? (constraints.biggest.height / 5.0 * 2.0) : _canvasSize,
              //height: !landscape ? (_canvasSize / 5.0 * 2.0) : constraints.biggest.height, 
              //use canvas height in landscape
              width :  landscape ? (_canvasSize / 5.0 * 2.0) : _canvasSize,
              height: !landscape ? (_canvasSize / 5.0 * 2.0) : _canvasSize, 
              child: ChangeNotifierProvider.value(
                value: GetIt.I<DrawingInterpreter>(),
                child: Consumer<DrawingInterpreter>(
                  builder: (context, interpreter, child){
                    return GridView.count(
                      padding: EdgeInsets.all(2),
                      physics: new NeverScrollableScrollPhysics(),
                      scrollDirection: landscape ? Axis.horizontal : Axis.vertical,
                      crossAxisCount: 5,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      
                      children: List.generate(10, (i) {
                        Widget widget = PredictionButton(interpreter.predictions[i]);
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
            ); 
            
            Widget grid = LayoutGrid(
              
              columnSizes: [1.fr, 1.fr, 1.fr, 1.fr, 1.fr], 
              rowSizes: [FixedTrackSize(_canvasSize), 1.fr, 1.fr, 1.fr],
              rowGap: 5,
              columnGap: 5,
              children: [
                Center(child: drawingCanvas).withGridPlacement(
                  columnStart: 0, rowStart: 0, columnSpan: 5 
                ),
                undoButton.withGridPlacement(
                    columnStart: 0, rowStart: 1
                ),
                Container(child: multiCharSearch, color: Colors.green).withGridPlacement(
                  columnStart: 1, rowStart: 1, columnSpan: 3, rowSpan: 1,
                ),
                clearButton.withGridPlacement(
                    columnStart: 4, rowStart: 1
                ),
                PredictionButton("1").withGridPlacement(
                    columnStart: 0, rowStart: 2
                ),
                PredictionButton("2").withGridPlacement(
                    columnStart: 1, rowStart: 2
                ),
                PredictionButton("3").withGridPlacement(
                    columnStart: 2, rowStart: 2
                ),
                PredictionButton("6").withGridPlacement(
                    columnStart: 0, rowStart: 3
                ),
              ],
            );

            return grid;
          }
        ),
      ),
    );
  }
}
