import 'package:flutter/material.dart';
import 'package:test_location_2nd/Util/global.dart' as global;
import 'package:test_location_2nd/Util/Util.dart';

class ZoomableWidgets {
  bool isZoomIn = false;
  List<Widget> widgets = [];
  Map layout = {};
  var provider;
  ZoomableWidgets(
      {required List<Widget> widgets,
        required Map layout,
        required bool isZoomIn,
        required provider}) {
    this.widgets = widgets;
    this.layout = layout;
    this.isZoomIn = isZoomIn;
    this.provider = provider;
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
      child: AnimatedRotation(
        turns: isZoomIn ? provider.zoomInAngle : 0,
        duration: Duration(milliseconds: global.animationTime),
        curve: global.animationCurve,
        child: Stack(alignment: Alignment.center, children: widgets),
      ),
    );
  }
}
