
import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';


class DefaultRectangleScatter extends StatelessWidget {
  double size;
  Color color;
  DefaultRectangleScatter({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(width: size, height: size,
      decoration:
      ShapeDecoration(shape: const Border(), color: color));
  }
}

class DefaultCircleScatter extends StatelessWidget {
  double size;
  Color color;
  DefaultCircleScatter({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(width: size, height: size,
        decoration:
        ShapeDecoration(shape: const CircleBorder(), color: color));
  }
}


class ImageScatter extends StatelessWidget {
  double size;
  Color color;
  String imagePath;
  ImageScatter({Key? key, required this.size, required this.color, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(width: size, height: size,
        decoration:
        ShapeDecoration(shape: const Border(), color: color),
    child : ExtendedImage.file(File(imagePath)));
  }
}
