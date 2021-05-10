import 'dart:ui';

import 'package:flutter/material.dart';

import '../globals.dart';


/// Da Kanji's drawer.
/// 
/// It connects the main screens of the app with each other.
/// Currently: *Drawing*, *Settings*, *About*
class DaKanjiDrawer extends StatefulWidget{

  /// The actual page to show when the drawer is not visible.
  final Widget child;

  DaKanjiDrawer(
    {@required this.child}
  );

  @override
  _DaKanjiDrawerState createState() => _DaKanjiDrawerState();
}

class _DaKanjiDrawerState extends State<DaKanjiDrawer> 
  with SingleTickerProviderStateMixin{

  AnimationController _drawerController;
  Animation _moveDrawer;

  double _drawerWidth;

  double _screenWidth;
  double _screenHeight;

  @override
  void initState() { 
    super.initState();
    _drawerController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );//..repeat(reverse: true);

    _moveDrawer = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate( CurvedAnimation(
      parent: _drawerController,
      curve: Interval(0.0, 1.0, curve: Curves.linear)
    ));
  }

  @override
  void dispose() { 
    _drawerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    _drawerWidth = MediaQuery.of(context).size.width * 0.5;
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;

    DragStartDetails _start;

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
                ..scale(
                  (1-_moveDrawer.value) * 0.5 + 0.5,
                  (1-_moveDrawer.value) * 0.5 + 0.5,
                )
                ..translate(
                  _screenWidth/2 * _moveDrawer.value, 
                )
                ..rotateY(_drawerController.value),
              child: SafeArea(
                child: Stack(
                  children: [
                    // the current screen
                    child,
                    GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(5)
                        ),
                        width: 50,
                        height: 50,
                        child: Icon(
                          Icons.menu,
                          color: Theme.of(context).primaryTextTheme.button.color
                        ),
                      ),
                      onTap: () => _drawerController.forward(from: 0.0),
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
                    opacity: _drawerController.value,
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
              child: SizedBox(
                height: _screenHeight,
                width: _drawerWidth,
                child: GestureDetector(
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
                    if(_drawerController.value < 0.5)
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
                          color: Colors.grey[800],
                          blurRadius: 10,
                        )
                      ],
                    ),
                    height: _screenHeight,
                    width: _drawerWidth,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        SizedBox(
                          height: MediaQuery.of(context).padding.top + 64 + 20,
                          child: DrawerHeader(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:[
                                Image( height: 84, image: AssetImage("media/banner.png"),),
                              ]
                            ),
                            margin: EdgeInsets.all(0),
                            padding: EdgeInsets.all(0),
                          ),
                        ),

                        // Drawer entry to go to the Kanji drawing screen
                        ListTile(
                          leading: Icon(Icons.brush_outlined),
                          title: Text("Drawing"),
                          onTap: () {
                            print(ModalRoute.of(context).settings.name);
                            if(ModalRoute.of(context).settings.name != "/drawing"){
                              Navigator.pushNamedAndRemoveUntil(
                                context, "/drawing", (Route<dynamic> route) => false);
                            }
                          },
                        ),

                        // Drawer entry to go to the settings screen
                        ListTile(
                          key: SHOWCASE_DRAWING[12].key,
                          leading: Icon(Icons.settings_applications),
                          title: Text("Settings"),
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context, "/settings", (Route<dynamic> route) => false);
                          },
                        ),

                        // Drawer entry to go to the about screen
                        ListTile(
                          leading: Icon(Icons.info_outline),
                          title: Text("About"),
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context, "/about", (Route<dynamic> route) => false);
                          },
                        ),
                      ],
                    )
                  ),
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}
