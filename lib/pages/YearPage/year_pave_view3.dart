import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:lateDiary/pages/setting_page.dart';
import 'year_page_view.dart';
import 'package:provider/provider.dart';

import 'package:lateDiary/StateProvider/year_page_state_provider.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:go_router/go_router.dart';

int size2 = 1;

class YearPageScreen3 extends StatefulWidget {
  static String id = '/year';

  @override
  State<YearPageScreen3> createState() => _YearPageScreen3State();
}

class _YearPageScreen3State extends State<YearPageScreen3> {
  bool isZoomIn = false;
  Duration duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    Color scatterColor = Colors.white.withAlpha(100);
    double left = -90;

    return Scaffold(
        body: Center(
            child: SizedBox(
      height: physicalWidth,
      width: physicalWidth,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          setState(() {
            isZoomIn = !isZoomIn;
            size2 = size2==1? 1:1;
          });
        },
        child: AnimatedScale(
          duration: duration,
          scale : isZoomIn? 2.5:1,
          child: Stack(alignment: Alignment.center, children: [
            AnimatedScale(
              duration : duration,
              scale : isZoomIn? 3:1,
              child: AnimatedPositioned(
                duration: duration,
                left: isZoomIn ? 60 : null,
                child: CustomPaint(
                  painter: OpenPainter(),
                ),
              ),
            ),

            AnimatedPositioned(
              duration: duration,
              left: isZoomIn ? left : 19,
              // left: 10
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                      15,
                      (index) => index > 8
                          ? Container(
                              width: 25,
                              child: RawMaterialButton(
                                  fillColor: scatterColor,
                                  shape: CircleBorder(),
                                  onPressed: () {print('bb');},
                                  child: Text("")))
                          : SizedBox(width: 25, height: 25 ))),
            ),
            AnimatedPositioned(
              duration: duration,
              left: isZoomIn ? left : 19,
              top : isZoomIn? 250:182,
              child: AnimatedRotation(
                duration: duration,
                turns: isZoomIn? 0: 1/10,
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                        15,
                        (index) => index > 8
                            ? Container(
                                width: 25,
                                child: RawMaterialButton(
                                    fillColor: scatterColor,
                                    shape: CircleBorder(),
                                    onPressed: () {},
                                    child: Text("")))
                            : Container(width: 25, height: 25))),
              ),
            ),

            AnimatedPositioned(
              duration: duration,
              left: isZoomIn ? left : 19,
              top : isZoomIn? 112:182,
              child: AnimatedRotation(
                duration: duration,
                turns: isZoomIn? 0: -1/10,
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                        15,
                            (index) => index > 8
                            ? Container(
                            width: 25,
                            child: RawMaterialButton(
                                fillColor: scatterColor,
                                shape: CircleBorder(),
                                onPressed: () {},
                                child: Text("")))
                            : Container(width: 25, height: 25))),
              ),
            ),
            AnimatedPositioned(
              duration: duration,
              left: isZoomIn ? left : 19,
              top : isZoomIn? 42:182,
              child: AnimatedRotation(
                duration: duration,
                turns: isZoomIn? 0: -2/10,
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                        15,
                            (index) => index > 8
                            ? Container(
                            width: 25,
                            child: RawMaterialButton(
                                fillColor: scatterColor,
                                shape: CircleBorder(),
                                onPressed: () {},
                                child: Text("")))
                            : Container(width: 25, height: 25))),
              ),
            ),   // Positioned(
            //   // left: 10
            //   child: Transform.rotate(
            //     angle: -pi / 2,
            //     child: Row(
            //         mainAxisSize: MainAxisSize.min,
            //         children: List.generate(
            //             15,
            //             (index) => index > 8
            //                 ? Container(
            //                     width: 25,
            //                     child: RawMaterialButton(
            //                         fillColor: scatterColor,
            //                         shape: CircleBorder(),
            //                         onPressed: () {},
            //                         child: Text("")))
            //                 : Container(width: 25, height: 25))),
            //   ),
            // ),
            // Positioned(
            //   // left: 10
            //   child: Transform.rotate(
            //     angle: pi,
            //     child: Row(
            //         mainAxisSize: MainAxisSize.min,
            //         children: List.generate(
            //             15,
            //             (index) => index > 8
            //                 ? Container(
            //                     width: 25,
            //                     child: RawMaterialButton(
            //                         fillColor: scatterColor,
            //                         shape: CircleBorder(),
            //                         onPressed: () {},
            //                         child: Text("")))
            //                 : Container(width: 25, height: 25))),
            //   ),
            // ),
          ]),
        ),
      ),
    )));
  }

  @override
  void dispose() {
    print("year page disposed");
  }
}

class OpenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(Offset(0, 0), physicalWidth * 3 / 7 * size2, paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
