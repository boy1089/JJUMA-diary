import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:lateDiary/StateProvider/year_page_state_provider.dart';
import 'package:lateDiary/Util/Util.dart';
import 'year_chart.dart';
import 'drop_down_button_2.dart';
import 'package:screenshot/screenshot.dart';

class template extends StatelessWidget {
  template({Key? key}) : super(key: key);
  var key = GlobalKey();

  //Create an instance of ScreenshotController
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RepaintBoundary(key: key, child: YearPageScreen()),
    );
  }
}

class YearPageScreen extends StatelessWidget {
  const YearPageScreen( {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Consumer<YearPageStateProvider>(
        builder: (context, product, child) => PhotoView.customChild(
          backgroundDecoration: BoxDecoration(color: Colors.black12),
          customSize: sizeOfChart,
          minScale: 1.0,
          onScaleEnd: (context, value, a) {
            product.setPhotoViewScale(a.scale ?? 1);
            if (product.photoViewScale! < 1) {
              product.setPhotoViewScale(1);
              product.setExpandedYear(null);
            }
          },
          child: Stack(
              alignment: Alignment.center,
              children: [

            CustomPaint(size: Size(0, 0), painter: OpenPainter()),
            ...List.generate(
                product.dataForChart2_modified.length > 10
                    ? 10
                    : product.dataForChart2_modified.length, (index) {
              int year = product.dataForChart2_modified.keys.elementAt(index);

              return YearChart(
                  year: year, radius: 1 - index * 0.1, product: product);
            }),
                Positioned(
                    right : sizeOfChart.height/4,
                    top : sizeOfChart.height/8,
                    child : CustomButtonTest())
          ]),
        ),

        // floatingActionButton: FloatingActionButton(
        //   onPressed: (){
        //     var a = Provider.of<YearPageStateProvider>(context, listen : false);
        //     print(a.dataForChart2_modified[2022].elementAt(95));
        //
        //     // for(int i = 0; i< a.dataForChart2_modified[2022].length; i++){
        //     //   print("$i, ${a.dataForChart2_modified[2022].elementAt(i)}");
        //     // }
        //
        //     for(int i = 0; i< a.dataForChart2_modified[2022].elementAt(80).elementAt(8).length; i++){
        //       print("$i, ${a.dataForChart2_modified[2022].elementAt(80).elementAt(8).elementAt(i)}");
        //     }
        //
        //   },
        // ),
      ),
    );
  }
}

Size sizeOfChart = Size(800, 800);

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
      fontSize: 16,
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
        maxWidth: 35,
      );

      textPainter.paint(canvas, Offset(xOffset-14, yOffset-7));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
