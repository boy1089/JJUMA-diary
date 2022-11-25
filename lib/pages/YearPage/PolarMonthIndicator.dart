import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:lateDiary/StateProvider/StateProvider.dart';
import 'package:provider/provider.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:intl/intl.dart';

import 'package:lateDiary/StateProvider/YearPageStateProvider.dart';
import 'package:lateDiary/StateProvider/DayPageStateProvider.dart';
import 'package:lateDiary/StateProvider/NavigationIndexStateProvider.dart';

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
            style: Theme.of(context).textTheme.headline2
          )),
    );
  }
}
