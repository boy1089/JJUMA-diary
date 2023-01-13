

import 'package:intl/intl.dart' as intl;
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:jjuma.d/Util/Util.dart';

class OpenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = const Color(0xff808080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    canvas.drawCircle(const Offset(0, 0), (physicalWidth / 2 - 3) * 0.3, paint1);
    canvas.drawCircle(const Offset(0, 0), physicalWidth / 2 - 3, paint1);

    var paint2 = Paint()
      ..color = const Color(0xff3f3f3f)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    double radius = physicalWidth / 2 * 1.2;
    //
    // var paint3 = Paint()..color = Colors.white;

    // canvas.drawCircle(Offset(rng.nextInt(800) - 400, rng.nextInt(800) - 400), 5, paint3);
    // for(int i = 0; i < 19; i++){
    //   canvas.drawCircle(Offset(randomNumber.elementAt(i) - 400, randomNumber.elementAt(i+1) - 400), 1, paint3);
    // }

    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
    );

    const textSpan = TextSpan(
      text: 'aa',
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    final intl.DateFormat formatter = intl.DateFormat('MMM');

    for (int i = 0; i < 12; i++) {
      double angle = 2 * pi / 12 * i + 2 * pi / 24 * 16;
      double xOffset = cos(angle) * radius;
      double yOffset = sin(angle) * radius;
      canvas.drawLine(const Offset(0, 0), Offset(xOffset, yOffset), paint2);

      final textSpan = TextSpan(
        text: '${formatter.format(DateTime(2022, i))}',
        style: textStyle,
      );

      textPainter..text = textSpan;
      textPainter.layout(
        minWidth: 0,
        maxWidth: 35,
      );

      textPainter.paint(canvas, Offset(xOffset - 14, yOffset - 7));
    }
  }



  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
