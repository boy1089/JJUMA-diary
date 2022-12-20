import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:lateDiary/StateProvider/year_page_state_provider.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:lateDiary/Util/Util.dart';
import 'year_chart.dart';

class YearPageScreen2 extends StatefulWidget {
  YearPageScreen2({Key? key}) : super(key: key);

  @override
  State<YearPageScreen2> createState() => _YearPageScreen2State();
}

Size sizeOfChart = Size(800, 800);

class _YearPageScreen2State extends State<YearPageScreen2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<YearPageStateProvider>(
        builder: (context, product, child) => PhotoView.customChild(
          customSize: sizeOfChart,
          minScale: 1.0,
          onScaleEnd: (context, value, a) {
            product.setPhotoViewScale(a.scale ?? 1);
            if (product.photoViewScale! < 1) {
              product.setPhotoViewScale(1);
              product.setExpandedYear(null);
            }
          },
          child: SizedBox(
            width: physicalWidth,
            height: physicalWidth,
            child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(size: Size(0, 0), painter: OpenPainter())
                ]..addAll(List.generate(product.dataForChart2.length>10? 9:product.dataForChart2.length, (index) {
                    int year = product.dataForChart2.keys.elementAt(index);
                    return YearChart(
                        year: year,
                        radius: 1 - index * 0.1,
                        isExpanded: (product.expandedYear == null) ||
                                (product.expandedYear != year)
                            ? false
                            : true,
                        product: product);
                  }))),
          ),
        ),
      ),
      
    );
  }
}

class OpenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = Color(0xff808080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    canvas.drawCircle(Offset(0, 0), (physicalWidth / 2 - 3) * 0.3, paint1);
    canvas.drawCircle(Offset(0, 0), physicalWidth / 2 - 3, paint1);

    var paint2 = Paint()
      ..color = Color(0xff3f3f3f)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    double radius = 240;

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 8,
    );

    final textSpan = TextSpan(
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
      canvas.drawLine(Offset(0, 0), Offset(xOffset, yOffset), paint2);

      final textSpan = TextSpan(
        text: '${formatter.format(DateTime(2022, i))}',
        style: textStyle,
      );

      textPainter..text = textSpan;
      textPainter.layout(
        minWidth: 0,
        maxWidth: 15,
      );

      textPainter.paint(canvas, Offset(xOffset, yOffset));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
