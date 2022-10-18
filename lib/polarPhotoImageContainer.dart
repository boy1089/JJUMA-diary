import 'dart:math';
import 'package:flutter/material.dart';
import 'package:googleapis/shared.dart';
import 'package:test_location_2nd/Util/Util.dart';




class polarPhotoImageContainers{
  var googlePhotoDataForPlot;
  double imageLocationFactor = 2.2;
  double imageSize = 100;
  double xLocation = 0;
  double yLocation = 0;
  double containerSize = kDefaultPolarPlotSize;

  polarPhotoImageContainers(@required googlePhotoDataForPlot, {containerSize : kDefaultPolarPlotSize}) {
    this.googlePhotoDataForPlot = googlePhotoDataForPlot;
    this.containerSize = containerSize;
  }

  @override
  Widget build(){
    return Stack(
      children: List<Widget>.generate(googlePhotoDataForPlot.length, (int index) => polarPhotoImageContainer(googlePhotoDataForPlot[index]).build())
    );
  }


}




class polarPhotoImageContainer {
  var googlePhotoDataForPlot;
  double imageLocationFactor = 2.2;
  double imageSize = 100;
  double xLocation = 0;
  double yLocation = 0;
  double containerSize = kDefaultPolarPlotSize;

  polarPhotoImageContainer(@required googlePhotoDataForPlot, {containerSize : kDefaultPolarPlotSize}) {
    this.googlePhotoDataForPlot = googlePhotoDataForPlot;
    this.containerSize = containerSize;

    xLocation = imageLocationFactor *
        cos((googlePhotoDataForPlot[0]) / 24 * 2 * pi - pi / 2);
    yLocation = imageLocationFactor *
        sin((googlePhotoDataForPlot[0]) / 24 * 2 * pi - pi / 2);
  }

  @override
  Widget build() {

    //outer container to make alignment consistent
    return Container(
        width: containerSize,
        height: containerSize,
      // alignment for circular positioning
        child: Align(
          alignment: Alignment(xLocation, yLocation),
          child: Container(
            width : imageSize,
            height : imageSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image : DecorationImage(
                fit : BoxFit.cover,
                image: NetworkImage(
                  googlePhotoDataForPlot[1],
                ),
              )
            )

            ),
          ),
        );
  }
}
