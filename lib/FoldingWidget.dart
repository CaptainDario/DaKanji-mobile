import 'dart:typed_data';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';



/// Folding Cell Widget
class FoldingWidget extends StatefulWidget {
  FoldingWidget(
      this.outerWidget,
      this.innerWidget,
      this.foldingKey,
      this.width,
      this.height,
      {this.unfoldCell = false,
      this.foldingColor = Colors.white,
      this.animationDuration = const Duration(milliseconds: 500),
      this.onOpen,
      this.onClose}) : super(key: foldingKey);

  // Front widget in folded cell
  final Widget outerWidget;

  /// Inner widget in unfolded cell
  final Widget innerWidget;
  
  //
  final GlobalKey foldingKey;

  final Color foldingColor;

  final double width;

  final double height;

  /// If true cell will be unfolded when created, if false cell will be folded when created
  final bool unfoldCell;

  /// Animation duration
  final Duration animationDuration;

  /// Called when cell fold animations completes
  final VoidCallback onOpen;

  /// Called when cell unfold animations completes
  final VoidCallback onClose;


  @override
  FoldingWidgetState createState() => FoldingWidgetState();
}

class FoldingWidgetState extends State<FoldingWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isUnfolded = true;
  
  AnimationController _animationController;
  Animation _animation1;
  Animation _animation2;
  Animation _animation3;
  Animation _animation4;

  Uint8List innerWidgetImage;


  @override
  void initState() {
    super.initState();
  
    final duration = 0.5;

    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animation1 = Tween<double>(
      begin: 0.0,
      end: 1.0
    ).animate( CurvedAnimation(
      parent: _animationController,
      curve: Interval(0*duration, 1*duration, curve: Curves.ease)
    ));
    _animation2 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate( CurvedAnimation(
      parent: _animationController,
      curve: Interval(1*duration, 2*duration, curve: Curves.ease)
    ));
    _animation3 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate( CurvedAnimation(
      parent: _animationController,
      curve: Interval(2*duration, 3*duration, curve: Curves.ease)
    ));
    _animation4 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate( CurvedAnimation(
      parent: _animationController,
      curve: Interval(3*duration, 4*duration, curve: Curves.ease)
    ));

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.onOpen != null) widget.onOpen();
      } else if (status == AnimationStatus.dismissed) {
        if (widget.onClose != null) widget.onClose();
        // mark the folding widget as completely unfolded
        setState(() {
          _isUnfolded = true;
        });
      }
    });

    if (widget.unfoldCell == true) {
      _animationController.value = 1;
      _isExpanded = true;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {

      double folds = 5;

      double sliceHeight = widget.height * 1/folds;

      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: () {
          if(!_isUnfolded)
            return Stack(

              clipBehavior: Clip.antiAlias,
              children: [
                // middle part of the image which stays in place
                Positioned(
                  top: sliceHeight*2,
                  child: ClipRect(
                    child: Transform.translate(
                      offset: Offset(0, -2*sliceHeight),
                      child: Align(
                        alignment: Alignment.topCenter,
                        heightFactor: 1/folds,
                        child: widget.innerWidget
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: sliceHeight,
                  child: innerSliceVertical(2,
                    hFactor: 1/folds,
                    bottomCard: false,
                  ),
                ),
                Positioned(
                  top: 0,
                  child: outerSliceVertical(
                    sliceHeight, widget.width, 1,
                    hFactor: 1/folds,
                    bottomCard: false
                  ),
                ),
                // 4th slice
                Positioned(
                  top: sliceHeight*3,
                  child: innerSliceVertical(4,
                    hFactor: 1/folds
                  ),
                ),
                // 5th slice
                Positioned(
                  top: sliceHeight*4,
                  child: outerSliceVertical(
                    sliceHeight, widget.width, 5,
                    hFactor: 1/folds
                  ),
                )
              ],
            );
          else
            return widget.innerWidget;
        } (),
      );
      }
    );
  }
  
  Widget outerSliceHorizontal(double height, double width, int sliceNumber, 
    {double hFactor = 1.0, double wFactor = 1.0, bool leftCard = true}){

    return Opacity(
      opacity: 1.0, //_animation1.value < 1.0 ? 1.0 : 0.0,
      child: Transform(
        transform: new Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY((leftCard ? -1 : 1) * _animation1.value * pi),
        alignment: leftCard 
          ? Alignment.centerRight
          : Alignment.centerLeft,
        child: Stack(
          children: [
            // inner
            Visibility(
              visible: _animation1.value < 0.5,
              child: Container(
                width: width,
                height: height,
                child: Opacity(
                  opacity: 1.0, //_animation1.value < 1.0 ? 1.0 : 0.0,
                  child: ClipRect(
                    child: Transform.translate(
                      offset: Offset(-(sliceNumber+1)*width, 2*height),
                      child: Align(
                        alignment: Alignment.topCenter,
                        heightFactor: hFactor,
                        widthFactor: wFactor,
                        child: widget.innerWidget 
                      ),
                    ),
                  ),
                ),
              )
            ),
            // outer 
            //Visibility(
            //  visible: true,//_animation1.value > 0.5,
            //  child: Container(
            //    width: width,
            //    height: height,
            //    color: widget.foldingColor,
            //  ),
            //),
          ],
        ),
      ),
    );
  }

  Widget innerSliceVertical(int sliceNumber,
    {double hFactor = 1.0, double wFactor = 1.0, bool bottomCard = true}){

    return Transform(
      transform: new Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX((bottomCard ? -1 : 1) * _animation2.value * pi),
      alignment: bottomCard
        ? Alignment.topCenter
        : Alignment.bottomCenter,
      child: Stack(
        children: [
          // outer
          Visibility(
            visible: _animation2.value > 0.0,
            child: () { 
              return Container(
                width: widget.width * wFactor,
                height: widget.height * hFactor,
                color: widget.foldingColor,
              );
            } ()
          ),
          Opacity(
            opacity: _animation1.value < 1.0 ? 1.0 : 0.0,
            child: ClipRect(
              child: Transform.translate(
                offset: Offset(0.0, -(sliceNumber)*widget.height),
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: hFactor,
                  widthFactor: wFactor,
                  child: widget.innerWidget 
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget outerSliceVertical(double height, double width, int sliceNumber, 
    {double hFactor = 1.0, double wFactor = 1.0, bool bottomCard = true}){

    return Opacity(
      opacity: _animation1.value < 1.0 ? 1.0 : 0.0,
      child: Transform(
        transform: new Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX((bottomCard ? -1 : 1) * _animation1.value * pi),
        alignment: bottomCard 
          ? Alignment.topCenter
          : Alignment.bottomCenter,
        child: Stack(
          children: [
            // inner
            Visibility(
              visible: _animation1.value < 0.5,
              child: ClipRect(
                child: Transform.translate(
                  offset: Offset(0, -(sliceNumber-1)*height),
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: hFactor,
                    widthFactor: wFactor,
                    child: widget.innerWidget 
                  ),
                ),
              ),
            ),
            // outer 
            Visibility(
              visible: _animation1.value > 0.5,
              child: Container(
                width: width,
                height: height,
                color: widget.foldingColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void toggleFold() async{

    if (_isExpanded) {
      _animationController.reverse();
    } 
    else {
      _animationController.forward();
      _isUnfolded = false;
    }
    _isExpanded = !_isExpanded;
  }
}

bool isInRange(double lower, double upper, double value){

  if(value > lower && value < upper)
    return true;
  else 
    return false;

}