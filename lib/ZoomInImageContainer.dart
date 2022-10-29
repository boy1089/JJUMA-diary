import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_location_2nd/Util/StateProvider.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'dart:math';

import 'package:extended_image/extended_image.dart';

class ZoomInImageContainer{
  bool isZoomInImageVisible = false;
  var googlePhotoDataForPlot = [];
  ZoomInImageContainer(this.isZoomInImageVisible, this.googlePhotoDataForPlot);


  @override
  Widget build(BuildContext context){
    print("ZoomInImageContainer, $isZoomInImageVisible");
    // return isZoomInImageVisible?
    // Container(
    //   child: polarPhotoImageContainer(googlePhotoDataForPlot[1],
    //   containerSize: 300.0).build(context),
    // )
    //     : Container();
    return
    Container(
      // child: polarPhotoImageContainer(googlePhotoDataForPlot[1],
      //     containerSize: 400.0).build(context),
    );



  }
}



class polarPhotoImageContainer {
  var googlePhotoDataForPlot;
  double zoomInFactor = 0.65;
  double imageLocationFactor = 1.4;
  double imageSize = 100;
  double defaultImageSize = 100;
  double zoomInImageSize = 300;
  double xLocation = 0;
  double yLocation = 0;
  double containerSize = kSecondPolarPlotSize;

  polarPhotoImageContainer(@required googlePhotoDataForPlot,
      {containerSize: kDefaultPolarPlotSize, applyOffset: true, index = 1}) {
    this.googlePhotoDataForPlot = googlePhotoDataForPlot;
    this.containerSize = containerSize;

    xLocation = imageLocationFactor * zoomInFactor*
        cos((googlePhotoDataForPlot[0]) / 24 * 2 * pi - pi / 2);
    yLocation = imageLocationFactor * zoomInFactor*
        sin((googlePhotoDataForPlot[0]) / 24 * 2 * pi - pi / 2);
    imageSize = defaultImageSize * 3;
  }

  @override
  Widget build(BuildContext context) {
    //outer container to make alignment consistent
    double angle = Provider.of<NavigationIndexProvider>(context, listen: false)
        .zoomInAngle;
    return Align(
      alignment: Alignment(xLocation, yLocation),
      child: SizedBox(
          width: imageSize,
          height: imageSize,
          // https://stackoverflow.com/questions/53866481/flutter-how-to-create-card-with-background-image
          child: AnimatedRotation(
            duration: Duration(milliseconds: 100),
            turns: -angle,
            child: Card(
                // shape: CircleBorder(),
                elevation: 4.0,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child:  ExtendedImage.network(
                  googlePhotoDataForPlot[1],
                  fit: BoxFit.none,
                  enableLoadState: false,
                )),
          )),
    );
  }
}
