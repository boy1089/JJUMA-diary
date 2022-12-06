import 'package:flutter/material.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:lateDiary/Util/Util.dart';

//TODO REMOVE provider
class ZoomableWidgets extends StatelessWidget{
  bool isZoomIn = false;
  List<Widget> widgets = [];
  Map layout = {};
  var provider;
  var gestures;
  ZoomableWidgets(
      {required List<Widget> widgets,
        required Map layout,
        required bool isZoomIn,
        required provider, required gestures}) {
    this.widgets = widgets;
    this.layout = layout;
    this.isZoomIn = isZoomIn;
    this.provider = provider;
    this.gestures = gestures;
  }
  late double graphSize = physicalWidth - 2 * global.kMarginForYearPage;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: global.animationTime),
      width: layout['graphSize']?[isZoomIn]?.toDouble(),
      height: layout['graphSize']?[isZoomIn]?.toDouble(),
      left: layout['left']?[isZoomIn]?.toDouble(),
      top: layout['top']?[isZoomIn]?.toDouble(),
      curve: global.animationCurve,
    child : RawGestureDetector(
    behavior: HitTestBehavior.deferToChild,
    gestures: gestures,
    child:
      AnimatedRotation(
        turns: isZoomIn ? provider.zoomInAngle : 0,
        duration: Duration(milliseconds: global.animationTime),
        curve: global.animationCurve,
        child: Stack(alignment: Alignment.center, children: widgets),
      ),
    ));
  }
}
