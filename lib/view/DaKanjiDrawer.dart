import 'dart:math';
import 'dart:ui';

import 'package:da_kanji_mobile/model/core/Screens.dart';
import 'package:da_kanji_mobile/model/core/SettingsArguments.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';


/// Da Kanji's drawer.
/// 
/// It connects the main screens of the app with each other.
/// Currently: *Drawing*, *Settings*, *About*
class DaKanjiDrawer extends StatefulWidget{

  /// The actual page to show when the drawer is not visible.
  final Widget child;
  /// The currently selected 
  final Screens currentScreen;
  /// should the animation begin at the start or end
  final bool animationAtStart;


  DaKanjiDrawer(
    {
      @required this.child,
      @required this.currentScreen,
      this.animationAtStart = true 
    }
  );

  @override
  _DaKanjiDrawerState createState() => _DaKanjiDrawerState();
}

class _DaKanjiDrawerState extends State<DaKanjiDrawer> 
  with SingleTickerProviderStateMixin{

  /// The controller for the drawer animation
  AnimationController _drawerController;
  /// The drawer animation
  Animation _moveDrawer;
  /// the width of the drawer
  double _drawerWidth;
  /// the width of the screen
  double _screenWidth;
  /// the height of the screen
  double _screenHeight;

  @override
  void initState() { 
    super.initState();
    _drawerController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _moveDrawer = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate( CurvedAnimation(
      parent: _drawerController,
      curve: Interval(0.0, 1.0, curve: Curves.linear)
    ));

    if(!widget.animationAtStart)
      _drawerController.value = 1.0;
  }

  @override
  void dispose() { 
    _drawerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    _drawerWidth = MediaQuery.of(context).size.width * 0.6;
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;

    DragStartDetails _start;
    
    // add a listener to when the Navigator animation finished
    var route = ModalRoute.of(context);
    void handler(status) {
      if (status == AnimationStatus.completed) {
        route.animation.removeStatusListener(handler);
        
        if(!widget.animationAtStart){
          SchedulerBinding.instance.addPostFrameCallback((_) async {
            _drawerController.reverse();
          });
        }
      }
    }
    route.animation.addStatusListener(handler);

    // create an drawer style application
    return AnimatedBuilder(
      animation: _drawerController,
      child: widget.child,
      builder: (BuildContext context, Widget child) {
        return Stack(
          children: [
            // the screen (child)
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..translate(_moveDrawer.value * _screenWidth/2)
                ..rotateY(pi/4 * _moveDrawer.value),
              child: SafeArea(
                child: Stack(
                  children: [
                    // the current screen
                    child,
                    Align(
                    alignment: Alignment.bottomLeft,
                      child: Material(
                        color: Theme.of(context).accentColor,
                        child: InkWell(
                          onTap: () => _drawerController.forward(from: 0.0),
                          child: Ink(
                            child: Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(75)
                                ), 
                              ),
                              child: Icon(
                                Icons.menu,
                                color: Theme.of(context).primaryTextTheme.button.color
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ),
            // overlay area which should close the drawer when tapped
            if(_drawerController.status != AnimationStatus.dismissed)
              Positioned(
                left: (_drawerWidth) * (_moveDrawer.value),
                top: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    _drawerController.reverse();
                  },
                  child: Opacity(
                    opacity: _moveDrawer.value,
                    child: Container(
                      color: Colors.grey[850].withAlpha(150),
                      width: _screenWidth,
                      height: _screenHeight,
                    ),
                  ),
                ),
              ), 
            // the drawer 
            if(_drawerController.status != AnimationStatus.dismissed)
            Transform.translate(
              offset: Offset(
                (-_drawerWidth) * (1-_moveDrawer.value), 
                0
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragStart: (DragStartDetails details){
                  if(_start == null)
                    _start = details;
                },
                onHorizontalDragUpdate: (DragUpdateDetails details){
                  var newState = _start.localPosition.dx - 
                    details.localPosition.dx;
                  _drawerController.value = 
                    1 - (newState / _drawerWidth).clamp(0.0, 1.0);
                },
                onHorizontalDragEnd: (DragEndDetails details){
                  _start = null;
                  if(_moveDrawer.value < 0.5)
                    _drawerController.reverse();
                  else
                    _drawerController.forward();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(10, 0),
                        //color: Colors.grey[800],
                        blurRadius: 10,
                      )
                    ],
                  ),
                  height: _screenHeight,
                  width: _drawerWidth,
                  child: ListView(
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).padding.top + 64 + 20,
                        child: DrawerHeader(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                              Image(
                                height: 84,
                                image: AssetImage("media/banner.png"),
                              ),
                            ]
                          ),
                          margin: EdgeInsets.all(0),
                          padding: EdgeInsets.all(0),
                        ),
                      ),

                      // Drawer entry to go to the Kanji drawing screen
                      Material(
                        child: ListTile(
                          leading: Icon(Icons.brush_outlined),
                          title: Text("Drawing"),
                          selected: widget.currentScreen == Screens.drawing,
                          onTap: () {
                            if(ModalRoute.of(context).settings.name != "/drawing"){
                              Navigator.pushNamedAndRemoveUntil(
                                context, "/drawing",
                                (Route<dynamic> route) => false,
                                arguments: SettingsArguments(true));
                            }
                            else{
                              _drawerController.reverse();
                            }
                          },
                        ),
                      ),

                      // Drawer entry to go to the settings screen
                      Material(
                        child: ListTile(
                          //key: SHOWCASE_DRAWING[12].key,
                          selected: widget.currentScreen == Screens.settings,
                          leading: Icon(Icons.settings_applications),
                          title: Text("Settings"),
                          onTap: () {
                            if(ModalRoute.of(context).settings.name != "/settings"){
                              Navigator.pushNamedAndRemoveUntil(
                                context, "/settings",
                                (Route<dynamic> route) => false,
                                arguments: SettingsArguments(true));
                            }
                            else{
                              _drawerController.reverse();
                            }
                          },
                        ),
                      ),
                      // Drawer entry to go to the about screen
                      Material(
                        child: ListTile(
                          selected: widget.currentScreen == Screens.about,
                          leading: Icon(Icons.info_outline),
                          title: Text("About"),
                          onTap: () {
                            if(ModalRoute.of(context).settings.name != "/about"){
                              Navigator.pushNamedAndRemoveUntil(
                                context, "/about",
                                (Route<dynamic> route) => false,
                                arguments: SettingsArguments(true));
                            }
                            else{
                              _drawerController.reverse();
                            }
                          },
                        ),
                      ),
                    ],
                  )
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}
