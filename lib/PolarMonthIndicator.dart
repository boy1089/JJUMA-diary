import 'dart:math';
import 'package:flutter/material.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:test_location_2nd/Util/StateProvider.dart';
import 'package:provider/provider.dart';
import 'package:test_location_2nd/Util/global.dart' as global;
import 'package:intl/intl.dart';

class PolarMonthIndicators {
  @override
  Widget build(BuildContext context) {
    return Provider.of<YearPageStateProvider>(context, listen: false).isZoomIn
        ? Stack(
            children: List<Widget>.generate(
                12, (int index) => PolarMonthIndicator(index).build(context)))
        : Text("");
  }
}

class PolarMonthIndicator {
  double imageLocationFactor = 1.4;
  double xLocation = 0;
  double yLocation = 0;
  double containerSize = kSecondPolarPlotSize;
  int index = -1;
  int numberOfImages = 0;

  PolarMonthIndicator(index) {
    this.containerSize = containerSize;
    this.index = index;
    this.numberOfImages = numberOfImages;
    xLocation = imageLocationFactor *
        cos((index) / 12 * 2 * pi - pi / 2) *
        (0.45 + 0.10 * 1);
    yLocation = imageLocationFactor *
        sin((index) / 12 * 2 * pi - pi / 2) *
        (0.45 + 0.1 * 1);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(xLocation, yLocation),
      child: Transform.rotate(
          angle: atan2(yLocation, xLocation),
          child: Text(
            "${DateFormat('MMM').format(DateTime(2022, index + 1))}",
            style: TextStyle(fontSize: 60, color: global.kColor_backgroundText),
          )),
    );
  }
}
