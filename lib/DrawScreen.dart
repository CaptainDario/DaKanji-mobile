import 'package:da_kanji_recognizer_mobile/KanjiBuffer.dart';
import 'package:da_kanji_recognizer_mobile/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'package:da_kanji_recognizer_mobile/DaKanjiRecognizerDrawer.dart';
import 'DrawingPainter.dart';
import 'PredictionButton.dart';
import 'KanjiBufferWidget.dart';

class DrawScreen extends StatefulWidget {
  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  DrawingPainter canvas;
  //the points which were drawn on the canvas
  List<List<Offset>> points = [];
  // the size of the canvas widget
  double canvasSize;
  // initialize predictions with blank
  List<String> predictions = List.generate(10, (index) => " ");
  // save the context for the Showcase view
  BuildContext myContext;
  // buffer for building a word
  KanjiBuffer kanjiBuffer = KanjiBuffer();

  
  // show case
  TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];


  @override
  void initState() {
    super.initState();

    // only show the showcase at an update/new install
    if(SHOW_SHOWCASE_DRAWING){
      initTargets();
      showTutorial();
    }

    // always rebuild the ui when the kanji buffer changed
    kanjiBuffer.addListener(() {
      setState(() { });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = (Theme.of(context).brightness == Brightness.dark);
    canvas = new DrawingPainter(points, darkMode);
    // init size of canvas and assure that it is min. 20 smaller than screen width
    canvasSize = MediaQuery.of(context).size.height * 3/6;
    if(canvasSize >= MediaQuery.of(context).size.width - 20)
      canvasSize = MediaQuery.of(context).size.width - 20;

    return Scaffold(
      key: DRAWER_KEY,
      appBar: AppBar(
        title: Text("Drawing"),
      ),
      drawer: DaKanjiRecognizerDrawer(),
      body: Center(
        child: Column( 
          children: [
            // the canvas to draw on
            Container(
              width: canvasSize,
              height: canvasSize,
              margin: EdgeInsets.fromLTRB(0, 
                (MediaQuery.of(context).size.width - canvasSize) / 2, 
                0, 0),
              child: GestureDetector(
                key: SHOWCASE_DRAWING[0].key,
                // drawing pointer moved
                onPanUpdate: (details) {
                  setState(() {
                    RenderBox renderBox = context.findRenderObject();
                    Offset point =
                        renderBox.globalToLocal(details.localPosition);
                    points[points.length - 1].add(point);
                  });
                },
                // started drawing
                onPanStart: (details) {
                  setState(() {
                    points.add([]);
                    RenderBox renderBox = context.findRenderObject();
                    Offset point =
                        renderBox.globalToLocal(details.localPosition);
                    points[points.length - 1].add(point);
                  });
                },
                // finished drawing a stroke
                onPanEnd: (details) async {
                  // remove single points and don't run inference for them
                  if (points[points.length - 1].length == 1)
                    points.removeLast();
                  else
                    predictions = await canvas.runInference();
                  setState(() {});
                },
                child: CustomPaint(
                  painter: canvas,
                ),
              ),
            ),
            Spacer(),
            // undo/clear button
            Container(
              width: canvasSize,
              child: Row(
                children: [
                  // undo
                  IconButton(
                    key: SHOWCASE_DRAWING[1].key,
                    icon: Icon(Icons.undo),
                    onPressed: () async {
                      //only run inference if canvas still has strokes
                      if(points.length > 1){
                        points.removeLast();
                        predictions = await canvas.runInference();
                      }
                      else{
                        points.removeLast();
                        predictions = List.generate(10, (i) => " ");
                      }
                      setState(() {});
                    }
                  ),
                  // multi character search input
                  Expanded(
                      child: Center(
                        key: SHOWCASE_DRAWING[6].key,
                        child: KanjiBufferWidget(
                          canvasSize: canvasSize,
                          kanjiBuffer: kanjiBuffer,
                        ),
                      )
                    //),
                  ),
                  // clear
                  IconButton(
                    key: SHOWCASE_DRAWING[2].key,
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        predictions = List.generate(10, (i) => " ");
                        points.clear();
                      });
                    }
                  ), 
                ]
              ),
            ),
            // prediction buttons
            Container(
              key: SHOWCASE_DRAWING[3].key,
              width: canvasSize,
              // approximated button height (width/5) * numRows + padding  
              height: (canvasSize / 5.0) * 2.0 + 10, 
              child: GridView.count(
                physics: new NeverScrollableScrollPhysics(),
                crossAxisCount: 5,
                children: List.generate(10, (i) {
                  var ret;
                  // instantiate short/long press showcase button
                  if(i == 0){
                    ret = Container(
                      key: SHOWCASE_DRAWING[4].key,
                      child: PredictionButton(
                        char: predictions[i],
                      )
                    );
                  }
                  // instantiate the other buttons
                  else ret = PredictionButton(char: predictions[i]);
                  
                  return GestureDetector(
                    child: ret,
                    onDoubleTap: (){
                      setState(() {
                        if(SETTINGS.emptyCanvasAfterDoubleTap)
                          points.clear();
                        kanjiBuffer.kanjiBuffer += predictions[i];
                      });
                    },
                  );
                },
                )
              )
            ),
            Spacer(),
          ],
        ),
      )
    );
  }
  

  void initTargets() {

    // canvas
    targets.add(createTutorialTargetFocus(0));
    // undo button
    targets.add(createTutorialTargetFocus(1));
    // clear button 
    targets.add(createTutorialTargetFocus(2));
    // predictions
    targets.add(createTutorialTargetFocus(3));
    // short press prediction button
    targets.add(createTutorialTargetFocus(4));
    // long press prediction button
    targets.add(createTutorialTargetFocus(5, keyIndex: 4));
    // multi char
    targets.add(createTutorialTargetFocus(6));
    //double tap prediction button 
    targets.add(createTutorialTargetFocus(7, keyIndex: 4));
    // short press multi char
    targets.add(createTutorialTargetFocus(8, keyIndex: 6));
    // long press multi char
    targets.add(createTutorialTargetFocus(9, keyIndex: 6));
    // double tap multi char
    targets.add(createTutorialTargetFocus(10, keyIndex: 6));
    // double tap
    targets.add(createTutorialTargetFocus(11, keyIndex: 6));
    // show settings
    targets.add(createTutorialTargetFocus(12));
  }

  TargetFocus createTutorialTargetFocus(int index, {int keyIndex}){
    return TargetFocus(
      identify: SHOWCASE_DRAWING[index].title,
      shape: ShapeLightFocus.RRect,
      color: SHOWCASE_VIGNETTE_COLOR,
      keyTarget: SHOWCASE_DRAWING[keyIndex ?? index].key,
      contents: [
        TargetContent(
          align: SHOWCASE_DRAWING[index].align,
          child: Container(
            child: Text(
              SHOWCASE_DRAWING[index].text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20.0
              ),
            ),
          )
        )
      ],
    );
  }
  
  void showTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      context,
      targets: targets,
      colorShadow: Colors.red,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        // close the drawer
        DRAWER_KEY.currentState.openEndDrawer();

        // don't show the tutorial again
        SHOW_SHOWCASE_DRAWING = false;
        SETTINGS.save();
      },
      onClickTarget: (target) {
        // open drawer after clicking on the swipe left showcase
        if(target.identify == SHOWCASE_DRAWING[11].title)
          DRAWER_KEY.currentState.openDrawer();
      },
      onSkip: () {
        // don't show the tutorial again
        SHOW_SHOWCASE_DRAWING = false;
        SETTINGS.save();
      },
      onClickOverlay: (target) {},
    )..show();
  }
}
