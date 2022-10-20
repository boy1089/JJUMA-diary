import 'dart:math';
import 'package:flutter/material.dart';
import 'package:googleapis/shared.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:extended_image/extended_image.dart';

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
          child: SizedBox(
            width : imageSize,
            height : imageSize,
              // https://stackoverflow.com/questions/53866481/flutter-how-to-create-card-with-background-image
              child : Card(
                shape: CircleBorder(),
                elevation : 0,
                clipBehavior: Clip.antiAliasWithSaveLayer,

                child: ExtendedImage.network(googlePhotoDataForPlot[1],
                // centerSlice: Rect.fromCircle(center: Offset(10.0, 10.0), radius : 10.0),
                  fit: BoxFit.cover,
                enableLoadState: false,
                cache : true,
                )
            //     child: FadeInImage.memoryNetwork(
            //       fadeInDuration: Duration(milliseconds: 700),
            //       fit: BoxFit.cover,
            //       placeholder: kTransparentImage, image:
            //         googlePhotoDataForPlot[1],
            // ),

              )

            ),
          ),
        );
  }
}
