import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

enum scatterType {
  defaultRect,
  defaultCircle,
  image,
}

abstract class Scatter extends StatelessWidget {
  double size;
  Color color;

  Scatter({required this.size, required this.color, required type});

  factory Scatter.fromType(imagePath,
      {required size, required color, required type}) {
    switch (type) {
      case scatterType.defaultCircle:
        return DefaultCircleScatter(size: size, color: color);
      case scatterType.defaultRect:
        return DefaultRectangleScatter(size: size, color: color);
      case scatterType.image:
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
      : super(size: size, color: color, type: scatterType.defaultRect);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size,
        height: size,
        decoration: ShapeDecoration(shape: const Border(), color: color));
  }
}

class DefaultCircleScatter extends Scatter {
  double size;
  Color color;
  DefaultCircleScatter({Key? key, required this.size, required this.color})
      : super(size: size, color: color, type: scatterType.defaultCircle);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size,
        height: size,
        decoration: ShapeDecoration(shape: const CircleBorder(), color: color));
  }
}

class ImageScatter extends Scatter {
  double size;
  Color color;
  String imagePath;
  ImageScatter(
      {Key? key,
      required this.size,
      required this.color,
      required this.imagePath})
      : super(size: size, color: color, type: scatterType.image);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size,
        height: size,
        decoration: ShapeDecoration(shape: const Border(), color: color),
        child: ExtendedImage.file(
          File(imagePath),
          compressionRatio: 0.05,
          cacheRawData: true,
          enableMemoryCache: true,
        ));
  }
}
