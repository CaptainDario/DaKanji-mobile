import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:tuple/tuple.dart';



Tuple2<bool, double> runInLandscape(BoxConstraints constraints, double canvasSize){

  bool landscape;

  // init size of canvas
  //landscape
  double cBHeight = constraints.biggest.height;
  double cBWidth = constraints.biggest.width;

  // set the app in landscape mode if there is space to
  // place the prediction buttons in two rows to the right of the canvas
  if(cBWidth > cBHeight*0.8 + cBHeight*0.8*0.4+10){
    var columnSpacing = 10;
    canvasSize = cBHeight * 0.8 - columnSpacing;
    landscape = true;
  }
  // portrait
  else{
    var predictionButtonheight = cBHeight * 0.35;
    var rowSpacing = 40;
    canvasSize = cBHeight - predictionButtonheight - rowSpacing;
    // assure that the canvas is not wider than the screen
    if(canvasSize > cBWidth)
      canvasSize = cBWidth - 10;

    landscape = false;
  }

  return Tuple2<bool, double>(landscape, canvasSize);
}

Widget responsiveLayout(
  Widget drawingCanvas, Widget predictionButtons, Widget multiCharSearch,
  Widget undoButton, Widget clearButton, double canvasSize, bool landscape){

  Widget layout;

  if(landscape)
    layout = landscapeLayout(drawingCanvas, predictionButtons, multiCharSearch, 
      undoButton, clearButton, canvasSize
    );
  else
    layout = portraitLayout(drawingCanvas, predictionButtons, multiCharSearch,
      undoButton, clearButton, canvasSize
    );

  return layout;
}

Widget portraitLayout(
  Widget drawingCanvas, Widget predictionButtons, Widget multiCharSearch,
  Widget undoButton, Widget clearButton, double canvasSize){
  
  Widget layout;
  
  layout = Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(color: Colors.green, child: drawingCanvas),
      SizedBox(height: 30,),
      multiCharSearch,
      SizedBox(height: 10,),
      predictionButtons
    ]
  );

  return layout;
}

/// 
Widget landscapeLayout(
  Widget drawingCanvas, Widget predictionButtons, Widget multiCharSearch,
  Widget undoButton, Widget clearButton, double canvasSize){

  Widget layout;

  layout = Center(
    child: LayoutGrid(
      //rowGap: 5,
      columnGap: 10,
      columnSizes: [
        FixedTrackSize(canvasSize), 
        FixedTrackSize(canvasSize * 0.2), 
        FixedTrackSize(canvasSize * 0.2)
      ], 
      rowSizes: [FixedTrackSize(canvasSize), FixedTrackSize(canvasSize*0.2)],
      children: [
        drawingCanvas.withGridPlacement(columnStart: 0, rowStart: 0),
        predictionButtons.withGridPlacement(
          columnStart: 1, columnSpan: 2, rowStart: 0
        ),
        multiCharSearch.withGridPlacement(columnStart: 0, rowStart: 1),
        Align(alignment: Alignment.topCenter, child: undoButton),
        clearButton
      ],
    ),
  );
  return layout;
}