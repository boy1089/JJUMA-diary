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
    print(googlePhotoDataForPlot.length);
    print(stackOrder);
    print(indexForZoomInImage);
    double angle =
        Provider.of<NavigationIndexProvider>(context, listen: true).zoomInAngle;
    return !Provider.of<NavigationIndexProvider>(context, listen: false)
            .isZoomIn
        ? Stack(
            children: List<Widget>.generate(
                googlePhotoDataForPlot.length,
                (int index) => polarPhotoImageContainer(
                        googlePhotoDataForPlot[stackOrder[index]],
                        index: stackOrder[index],
                        numberOfImages: stackOrder.length)
                    .build(context)))
        : Stack(
            children: List<Widget>.generate(
                googlePhotoDataForPlot.length,
                (int index) => polarPhotoImageContainer(
                        googlePhotoDataForPlot[stackOrder[index]],
                        applyOffset: false,
                        index: stackOrder[index],
                        numberOfImages: stackOrder.length)
                    .build(context)));
  }
}

class polarPhotoImageContainer {
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

  polarPhotoImageContainer(@required googlePhotoDataForPlot,
      {containerSize: kDefaultPolarPlotSize,
      applyOffset: true,
      index = 1,
      numberOfImages}) {
    this.googlePhotoDataForPlot = googlePhotoDataForPlot;
    this.containerSize = containerSize;
    this.index = index;
    this.numberOfImages = numberOfImages;

    if (applyOffset) {
      xLocation = imageLocationFactor *
          cos((googlePhotoDataForPlot[0]) / 24 * 2 * pi - pi / 2);
      yLocation = imageLocationFactor *
          sin((googlePhotoDataForPlot[0]) / 24 * 2 * pi - pi / 2);
    } else {
      var radiusSign = 1;
      var radius = (index % 5) / 1.8; // mag5 1.2

      xLocation = imageLocationFactor *
          cos((googlePhotoDataForPlot[0]) / 24 * 2 * pi - pi / 2) *
          (0.45 + 0.10 * radiusSign * radius);
      yLocation = imageLocationFactor *
          sin((googlePhotoDataForPlot[0]) / 24 * 2 * pi - pi / 2) *
          (0.45 + 0.1 * radiusSign * radius);
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
              turns:
                  Provider.of<NavigationIndexProvider>(context, listen: false)
                          .isZoomIn
                      ? -angle
                      : 0,
              child: RawGestureDetector(
                  gestures: {
                    AllowMultipleGestureRecognizer:
                        GestureRecognizerFactoryWithHandlers<
                                AllowMultipleGestureRecognizer>(
                            () => AllowMultipleGestureRecognizer(),
                            (AllowMultipleGestureRecognizer instance) {
                      instance.onTapUp = (details) {
                        print(
                            "image container ${this.index} / ${numberOfImages} clicked");

                        if (this.index == indexForZoomInImage) {
                          indexForZoomInImage = this.index + 1;
                          if (this.index == numberOfImages - 1) {
                            indexForZoomInImage = 0;
                          }
                        } else {
                          indexForZoomInImage = this.index;
                        }
                        isImageClicked = true;
                      };
                    })
                  },

                  child: Card(
                    elevation: 3,
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
                            enableMemoryCache: true,
                            // cacheRawData: true,
                            compressionRatio: 0.05,
                            // scale : 0.2
                          ),
                  )))),
    );
  }
}
