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
  // place the prediction buttons in two rows 
  if(cBWidth > cBHeight*0.8 + cBHeight*0.8*0.4+10){
    canvasSize = cBHeight * 0.8;
    landscape = true;
  }
  // portrait
  else{
    canvasSize = cBWidth - 20;
    // assure that there is enough space for the PredictionButtons
    if(canvasSize > cBHeight * 0.66)
    canvasSize = cBHeight * 0.66;
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
      drawingCanvas,
      multiCharSearch,
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
      //columnGap: 5,
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
        undoButton,
        clearButton
      ],
    ),
  );
  return layout;
}