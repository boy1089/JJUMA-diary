import 'dart:math';
import 'package:flutter/material.dart';
import 'package:googleapis/shared.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:test_location_2nd/StateProvider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class polarPhotoImageContainers {
  var googlePhotoDataForPlot;
  double imageLocationFactor = 2.2;
  double imageSize = 100;
  double xLocation = 0;
  double yLocation = 0;
  double containerSize = kDefaultPolarPlotSize;
  polarPhotoImageContainers(
    @required googlePhotoDataForPlot, {
    containerSize: kDefaultPolarPlotSize,
  }) {
    this.googlePhotoDataForPlot = googlePhotoDataForPlot;
    this.containerSize = containerSize;
  }

  @override
  Widget build(BuildContext context) {
    print("rebuild!!?");
    double angle = Provider.of<NavigationIndexProvider>(context, listen: false)
        .zoomInAngle;
    return angle == 0
        ? Stack(
            children: List<Widget>.generate(
                googlePhotoDataForPlot.length,
                (int index) => polarPhotoImageContainer(
                      googlePhotoDataForPlot[index],
                    ).build(context)))
        : Stack(
            children: List<Widget>.generate(
                googlePhotoDataForPlot.length,
                (int index) => polarPhotoImageContainer(
                        googlePhotoDataForPlot[index],
                        applyOffset: false,
                        index: index)
                    .build(context)));
  }
}

class polarPhotoImageContainer {
  var googlePhotoDataForPlot;
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

    if (applyOffset) {
      xLocation = imageLocationFactor *
          cos((googlePhotoDataForPlot[0]) / 24 * 2 * pi - pi / 2);
      yLocation = imageLocationFactor *
          sin((googlePhotoDataForPlot[0]) / 24 * 2 * pi - pi / 2);
    } else {
      var radiusSign = ((index/2).floor()%2 - 0.5) *2;
      var radius = (index % 3)/1.8;  // mag5 1.2


      xLocation = imageLocationFactor *
          cos((googlePhotoDataForPlot[0]) / 24 * 2 * pi - pi / 2) *
          (0.6 + 0.10 * radiusSign * radius);
      yLocation = imageLocationFactor *
          sin((googlePhotoDataForPlot[0]) / 24 * 2 * pi - pi / 2) *
          (0.6 + 0.1 * radiusSign * radius);
    }
  }

  @override
  Widget build(BuildContext context) {
    //outer container to make alignment consistent

    print(googlePhotoDataForPlot);
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
            child: GestureDetector(
              onTap: (){
                print("gesture detected1");
                if(angle != 0.0) {

                  imageSize = 300;
                }
              },
              child: Card(
                  shape: CircleBorder(),
                  elevation: 4.0,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child:
                  googlePhotoDataForPlot[1].length>200
                  ?ExtendedImage.network(
                    googlePhotoDataForPlot[1],
                    // centerSlice: Rect.fromCircle(center: Offset(10.0, 10.0), radius : 10.0),
                    fit: BoxFit.cover,
                    enableLoadState: false,
                  )
                      :ExtendedImage.file(File(googlePhotoDataForPlot[1]),
                    fit: BoxFit.cover,
                    enableLoadState: false,
                  )
              ),
            ),
          )),
    );
  }
}
