
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
