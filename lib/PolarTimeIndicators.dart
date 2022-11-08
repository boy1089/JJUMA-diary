import 'dart:math';
import 'package:flutter/material.dart';
// import 'package:googleapis/shared.dart';
import 'package:graphic/graphic.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:test_location_2nd/Util/StateProvider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:test_location_2nd/Util/global.dart' as global;

class PolarTimeIndicators extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // print("PolarTimeIndicators build");
    return Provider.of<UiStateProvider>(context, listen: true).isZoomIn
        ? Stack(
            children: List<Widget>.generate(
                24, (int index) => PolarTimeIndicator(index).build(context)))
        : Text("");
    // return Stack(
    // children: List<Widget>.generate(
    //     24, (int index) => PolarTimeIndicator(index).build(context)));
  }
}

class PolarTimeIndicator {
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

  PolarTimeIndicator(index) {
    this.containerSize = containerSize;
    this.index = index;
    this.numberOfImages = numberOfImages;
    xLocation = imageLocationFactor *
        cos((index) / 24 * 2 * pi - pi / 2) *
        (0.45 + 0.10 * 1);
    yLocation = imageLocationFactor *
        sin((index) / 24 * 2 * pi - pi / 2) *
        (0.45 + 0.1 * 1);
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<UiStateProvider>(context, listen: true);
    return Align(
      alignment:  Alignment(xLocation, yLocation),
      child: AnimatedRotation(
          duration: const Duration(milliseconds: 100),
          turns: provider.isZoomIn
              ? -provider.zoomInAngle
              : 0,
          // turns : 0,
          child: Text(
            "$index",
            style: TextStyle(fontSize: 60, color: global.kColor_backgroundText),
          )),
    );
  }
}
