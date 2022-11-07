import 'dart:math';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:test_location_2nd/Util/StateProvider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:test_location_2nd/Util/global.dart' as global;
import 'package:intl/intl.dart';
class PolarMonthIndicators {
  @override
  Widget build(BuildContext context) {
    return
      Provider.of<NavigationIndexProvider>(context, listen: false)
          .isZoomIn
          ?Stack(
          children: List<Widget>.generate(
              12, (int index) => PolarMonthIndicator(index).build(context)))
          :Text("");
  }
}

class PolarMonthIndicator {
  var googlePhotoDataForPlot;
  double imageLocationFactor = 1.4;
  double imageSize = 90;
  double defaultImageSize = 100;
  double zoomInImageSize = 300;
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
    double angle = Provider.of<NavigationIndexProvider>(context, listen: false)
        .zoomInAngle;
    return Align(
      alignment: Alignment(xLocation, yLocation),
      child: AnimatedRotation(
          duration: Duration(milliseconds: 100),
          turns: Provider.of<NavigationIndexProvider>(context, listen: false)
              .isZoomIn
              ? -angle
              : 0,
          child: Text(
            "${DateFormat('MMM').format(DateTime(2022, index+1))}",
            style: TextStyle(fontSize: 60, color: global.kColor_backgroundText),
          )),
    );
  }
}