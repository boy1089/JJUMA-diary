import 'dart:math';
import 'package:flutter/material.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:extended_image/extended_image.dart';
import 'package:test_location_2nd/StateProvider/StateProvider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:test_location_2nd/Util/global.dart';

import 'package:test_location_2nd/StateProvider/YearPageStateProvider.dart';
import 'package:test_location_2nd/StateProvider/DayPageStateProvider.dart';
import 'package:test_location_2nd/StateProvider/NavigationIndexStateProvider.dart';

class polarPhotoImageContainers {
  var photoDataForPlot;
  double xLocation = 0;
  double yLocation = 0;
  List stackOrder = [];
  polarPhotoImageContainers(@required photoDataForPlot) {
    this.photoDataForPlot = photoDataForPlot;

    if (indexForZoomInImage == -1) {
      stackOrder = List.generate(photoDataForPlot.length, (int index) => index);
    } else {
      stackOrder = List.generate(indexForZoomInImage, (int index) => index) +
          List.generate(photoDataForPlot.length - indexForZoomInImage - 1,
              (int index) => indexForZoomInImage + index + 1) +
          [indexForZoomInImage];
    }
  }

  @override
  Widget build(BuildContext context) {
    // print("imageContainers build");
    return !Provider.of<DayPageStateProvider>(context, listen: false).isZoomIn
        ? Stack(
            children: List<Widget>.generate(
                photoDataForPlot.length,
                (int index) => polarPhotoImageContainer(
                        photoDataForPlot[stackOrder[index]],
                        index: stackOrder[index],
                        numberOfImages: stackOrder.length)
                    .build(context)))
        : Stack(
            children: List<Widget>.generate(
                photoDataForPlot.length,
                (int index) => polarPhotoImageContainer(
                        photoDataForPlot[stackOrder[index]],
                        applyOffset: false,
                        index: stackOrder[index],
                        numberOfImages: stackOrder.length)
                    .build(context)));
  }
}

class polarPhotoImageContainer {
  var photoDataForPlot;
  double imageLocationFactor = 1.4;
  double imageSize = kImageSize;
  double xLocation = 0;
  double yLocation = 0;
  Offset location = Offset(0, 0);
  double containerSize = kSecondPolarPlotSize;
  int index = -1;
  int numberOfImages = 0;

  polarPhotoImageContainer(@required googlePhotoDataForPlot,
      {containerSize: kDefaultPolarPlotSize,
      applyOffset: true,
      index = 1,
      numberOfImages}) {
    this.photoDataForPlot = googlePhotoDataForPlot;
    this.containerSize = containerSize;
    this.index = index;
    this.numberOfImages = numberOfImages;
    location = calculateLocation(googlePhotoDataForPlot[0], applyOffset);
  }

  Offset calculateLocation(input, applyOffset) {
    double angle = (input) / 24 * 2 * pi - pi / 2;

    if (applyOffset) {
      xLocation = imageLocationFactor * cos(angle);
      yLocation = imageLocationFactor * sin(angle);
    } else {
      var radius = (index % 5) / 1.8; // mag5 1.2
      xLocation = imageLocationFactor * cos(angle) * (0.45 + 0.10 * radius);
      yLocation = imageLocationFactor * sin(angle) * (0.45 + 0.1 * radius);
    }

    if (indexForZoomInImage == this.index) {
      imageSize = kZoomInImageSize;
      var radiusSign = (1 - 0.7) * 2;
      var radius = (2) / 1.8; // mag5 1.2

      xLocation = imageLocationFactor *
          cos(angle - pi * 0.04) *
          (0.6 + 0.10 * radiusSign * radius);
      yLocation = imageLocationFactor *
          sin(angle - pi * 0.04) *
          (0.6 + 0.1 * radiusSign * radius);
    }
    return Offset(xLocation, yLocation);
  }

  Offset calculateLocationForZoomInImage(input, angleOfPage){
    double angle = (input) / 24 * 2 * pi - pi / 2 - angleOfPage/(2*pi);
    imageSize = kZoomInImageSize;
    var radiusSign = (1 - 0.7) * 2;
    var radius = (2) / 1.8; // mag5 1.2

    xLocation = imageLocationFactor *
        cos(angle - pi * 0.04) *
        (0.6 + 0.10 * radiusSign * radius);
    yLocation = imageLocationFactor *
        sin(angle - pi * 0.04) *
        (0.6 + 0.1 * radiusSign * radius);
  return Offset(xLocation, yLocation);
  }

  @override
  Widget build(BuildContext context) {
    double angle =
        Provider.of<DayPageStateProvider>(context, listen: false).zoomInAngle;
    bool isZoomIn =
        Provider.of<DayPageStateProvider>(context, listen: false).isZoomIn;

    return Align(
      alignment: !(indexForZoomInImage == this.index)
          ? Alignment(location.dx, location.dy)
          : Alignment(calculateLocationForZoomInImage(photoDataForPlot[0], angle).dx,
          calculateLocationForZoomInImage(photoDataForPlot[0], angle).dy),
      child: SizedBox(
          width: imageSize,
          height: imageSize,
          // https://stackoverflow.com/questions/53866481/flutter-how-to-create-card-with-background-image
          child: AnimatedRotation(
              duration: Duration(milliseconds: 100),
              turns: isZoomIn ? -angle : 0,
              child: Offstage(
                offstage: isZoomIn ? false : !photoDataForPlot[3],
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
                      child: ExtendedImage.file(
                        File(photoDataForPlot[1]),
                        loadStateChanged: (ExtendedImageState state) {
                          switch (state.extendedImageLoadState) {
                            case LoadState.loading:
                              break;
                            case LoadState.completed:
                              return ExtendedRawImage(
                                image: state.extendedImageInfo?.image,
                                fit: BoxFit.cover,
                                // imageCacheName: photoDataForPlot[1],
                              );
                          }
                        },
                        // imageCacheName: photoDataForPlot[1],
                        enableLoadState: false,
                        enableMemoryCache: true,
                        compressionRatio: 0.01,
                      ),
                    )),
              ))),
    );
  }

  @override
  void dispose() {
    clearMemoryImageCache(photoDataForPlot[1]);
  }
}
