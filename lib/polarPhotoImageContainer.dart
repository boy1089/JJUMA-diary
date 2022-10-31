import 'dart:math';
import 'package:flutter/material.dart';
import 'package:googleapis/shared.dart';
import 'package:graphic/graphic.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:test_location_2nd/Util/StateProvider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:test_location_2nd/Util/global.dart';

Color defaultColor = Colors.black;

class polarPhotoImageContainers {
  var googlePhotoDataForPlot;
  double imageLocationFactor = 2.2;
  double imageSize = 100;
  double xLocation = 0;
  double yLocation = 0;
  double containerSize = kDefaultPolarPlotSize;
  List stackOrder = [];
  polarPhotoImageContainers(
    @required googlePhotoDataForPlot, {
    containerSize: kDefaultPolarPlotSize,
  }) {
    this.googlePhotoDataForPlot = googlePhotoDataForPlot;
    this.containerSize = containerSize;

    if (indexForZoomInImage == -1) {
      stackOrder =
          List.generate(googlePhotoDataForPlot.length, (int index) => index);
    } else {
      stackOrder = List.generate(indexForZoomInImage, (int index) => index) +
          List.generate(googlePhotoDataForPlot.length - indexForZoomInImage - 1,
              (int index) => indexForZoomInImage + index + 1) +
          [indexForZoomInImage];
    }
  }

  @override
  Widget build(BuildContext context) {
    print(stackOrder);
    double angle = Provider.of<NavigationIndexProvider>(context, listen: true)
        .zoomInAngle;
    return !Provider.of<NavigationIndexProvider>(context, listen: false).isZoomIn
        ? Stack(
            children: List<Widget>.generate(
                googlePhotoDataForPlot.length,
                (int index) => polarPhotoImageContainer(
                        googlePhotoDataForPlot[stackOrder[index]],
                        index: stackOrder[index])
                    .build(context)))
        : Stack(
            children: List<Widget>.generate(
                googlePhotoDataForPlot.length,
                (int index) => polarPhotoImageContainer(
                        googlePhotoDataForPlot[stackOrder[index]],
                        applyOffset: false,
                        index: stackOrder[index])
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
  int index = -1;

  polarPhotoImageContainer(@required googlePhotoDataForPlot,
      {containerSize: kDefaultPolarPlotSize, applyOffset: true, index = 1}) {
    this.googlePhotoDataForPlot = googlePhotoDataForPlot;
    this.containerSize = containerSize;
    this.index = index;

    if (applyOffset) {
      xLocation = imageLocationFactor *
          cos((googlePhotoDataForPlot[0]) / 24 * 2 * pi - pi / 2);
      yLocation = imageLocationFactor *
          sin((googlePhotoDataForPlot[0]) / 24 * 2 * pi - pi / 2);
    } else {
      var radiusSign = ((index / 2).floor() % 2 - 0.5) * 2;
      var radius = (index % 3) / 1.8; // mag5 1.2

      xLocation = imageLocationFactor *
          cos((googlePhotoDataForPlot[0]) / 24 * 2 * pi - pi / 2) *
          (0.6 + 0.10 * radiusSign * radius);
      yLocation = imageLocationFactor *
          sin((googlePhotoDataForPlot[0]) / 24 * 2 * pi - pi / 2) *
          (0.6 + 0.1 * radiusSign * radius);
    }

    if (indexForZoomInImage == this.index) {
      imageSize = 350;
      var radiusSign = (1 - 0.7) * 2;
      var radius = (2) / 1.8; // mag5 1.2

      xLocation = imageLocationFactor *
          cos((googlePhotoDataForPlot[0]) / 24 * 2 * pi - pi / 2 - pi * 0.04) *
          (0.6 + 0.10 * radiusSign * radius);
      yLocation = imageLocationFactor *
          sin((googlePhotoDataForPlot[0]) / 24 * 2 * pi - pi / 2 - pi * 0.04) *
          (0.6 + 0.1 * radiusSign * radius);
    }
  }
  @override
  void dispose(){
    indexForZoomInImage = -1;
  }

  @override
  Widget build(BuildContext context) {
    //outer container to make alignment consistent

    // print(googlePhotoDataForPlot);
    // print("polarPhotoImageContainer, imagesize : $imageSize");
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
              turns: Provider.of<NavigationIndexProvider>(context, listen: false).isZoomIn?-angle:0,
              child: RawGestureDetector(
                  gestures: {
                    AllowMultipleGestureRecognizer:
                        GestureRecognizerFactoryWithHandlers<
                                AllowMultipleGestureRecognizer>(
                            () => AllowMultipleGestureRecognizer(),
                            (AllowMultipleGestureRecognizer instance) {
                      instance.onTapUp = (details) {
                        print("clicked");
                        indexForZoomInImage = this.index;
                        print(indexForZoomInImage);
                      };
                    })
                  },
                  // child : Container(
                  //     // width : 400, height : 400,
                  //     color : defaultColor),

                  child: Card(
                    shape: CircleBorder(),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: googlePhotoDataForPlot[1].length > 200
                        ? ExtendedImage.network(
                            googlePhotoDataForPlot[1],
                            // centerSlice: Rect.fromCircle(center: Offset(10.0, 10.0), radius : 10.0),
                            fit: BoxFit.cover,
                            enableLoadState: false,
                          )
                        : ExtendedImage.file(
                            File(googlePhotoDataForPlot[1]),
                            fit: BoxFit.cover,
                            enableLoadState: false,
                          ),
                  )))),
    );
  }
}
