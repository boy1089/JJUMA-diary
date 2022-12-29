import 'package:flutter/material.dart';
import 'package:JJUMA.d/Util/global.dart' as global;
import 'package:JJUMA.d/Util/Util.dart';

class ZoomableWidgets extends StatelessWidget {
  bool isZoomIn = false;
  List<Widget> widgets = [];
  Map layout = {};
  double angle;
  var gestures;

  ZoomableWidgets(
      {super.key, required this.widgets,
      required this.layout,
      required this.isZoomIn,
      required this.gestures,
      required this.angle});
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
        duration: Duration(milliseconds: global.animationTime),
        width: layout['graphSize']?[isZoomIn]?.toDouble(),
        height: layout['graphSize']?[isZoomIn]?.toDouble(),
        left: layout['left']?[isZoomIn]?.toDouble(),
        top: layout['top']?[isZoomIn]?.toDouble(),
        curve: global.animationCurve,
        child: AnimatedScale(
          duration: Duration(milliseconds: global.animationTime),
          curve: global.animationCurve,
          scale : isZoomIn? 2:1,
          child: RawGestureDetector(
            behavior: HitTestBehavior.deferToChild,
            gestures: gestures,
            child: AnimatedRotation(
              turns: isZoomIn ? angle : 0,
              duration: Duration(milliseconds: global.animationTime),
              curve: global.animationCurve,
              child: Stack(alignment: Alignment.center, children: widgets),
            ),
          ),
        ));
  }
}
