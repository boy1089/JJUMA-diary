import 'dart:async';
import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

enum ScatterType {
  defaultRect,
  defaultCircle,
  image,
}

abstract class Scatter extends StatelessWidget {
  final double size;
  final Color color;

  const Scatter(
      {super.key, required this.size, required this.color, required type});

  factory Scatter.fromType(imagePath,
      {required size, required color, required type}) {
    switch (type) {
      case ScatterType.defaultCircle:
        return DefaultCircleScatter(size: size, color: color);
      case ScatterType.defaultRect:
        return DefaultRectangleScatter(size: size, color: color);
      case ScatterType.image:
        return ImageScatter(size: size, color: color, imagePath: imagePath);

      default:
        return DefaultCircleScatter(size: size, color: color);
    }
  }

  @override
  Widget build(BuildContext context);
}

class DefaultRectangleScatter extends Scatter {
  double size;
  Color color;
  DefaultRectangleScatter({Key? key, required this.size, required this.color})
      : super(size: size, color: color, type: ScatterType.defaultRect);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size,
        height: size,
        decoration: ShapeDecoration(shape: const Border(), color: color));
  }
}

class ImageScatter extends Scatter {
  final double size;
  final Color color;
  String imagePath;
  double aspectRatio = 1;
  late double width;

  late File file;
  late ExtendedImage extendedImage;
  ImageScatter(
      {Key? key,
      required this.size,
      required this.color,
      required this.imagePath})
      : super(size: size, color: color, type: ScatterType.image) {
    file = File(imagePath);
    extendedImage = ExtendedImage.file(File(imagePath),
        compressionRatio: 0.05,
        cacheRawData: true,
        enableMemoryCache: true,
        fit: BoxFit.cover);
  }

  getAspectRatio() async {
    final c = new Completer<ImageInfo>();
    extendedImage.image
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((image, synchronousCall) {
      c.complete(image);
    }));
    var info = (await c.future).image;
    aspectRatio = info.width / info.height;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size,
        height: size * aspectRatio,
        decoration: ShapeDecoration(
          shape: const Border(),
          color: color,
        ),
        child: extendedImage);
  }
}

class DefaultCircleScatter extends Scatter {
  final double size;
  final Color color;
  const DefaultCircleScatter({Key? key, required this.size, required this.color})
      : super(size: size, color: color, type: ScatterType.defaultCircle);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size,
        height: size,
        decoration: ShapeDecoration(shape: const CircleBorder(), color: color));
  }
}
