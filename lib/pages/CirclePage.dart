import 'package:flutter/material.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:test_location_2nd/Util/global.dart';

class CirclePage extends StatefulWidget {
  const CirclePage({Key? key}) : super(key: key);

  @override
  State<CirclePage> createState() => _CirclePageState();
}

class _CirclePageState extends State<CirclePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: kBackGroundColor,
        width: physicalWidth,
        height: physicalHeight,
        child: CustomPaint(foregroundPainter: LinePainter()),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     int numberOfPhotoIn2022 = 0;
      //     for(int i  = 5; i< summaryOfPhotoData.length; i++){
      //       String key = summaryOfPhotoData.keys.elementAt(i);
      //       print(key);
      //       if (key.contains("2022")){
      //         print(key);
      //         print(summaryOfPhotoData[key]);
      //         numberOfPhotoIn2022 += int.parse(summaryOfPhotoData[key].toString());
      //         // numberOfPhotoIn2022 = numberOfPhotoIn2022 + summaryOfPhotoData[key];
      //       }
      //     }
      //     print(numberOfPhotoIn2022);
      //   },
      // ),
    );
  }
}

class LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double radius = physicalWidth / 2 - 50;
    final paint = Paint()
      ..color = Colors.blue.withAlpha(200)
      ..strokeWidth = 50
      ..style = PaintingStyle.stroke
      ..shader = SweepGradient(
        colors: [Colors.blue, Colors.red, Colors.blue, Colors.red],
      ).createShader(Rect.fromCircle(
          center: Offset(physicalWidth / 2, physicalHeight / 2),
          radius: radius));

    final a = Offset(size.width, size.height);
    final b = Offset(0, 0);

    final rect = Rect.fromPoints(a, b);
    canvas.drawCircle(
        Offset(physicalWidth / 2, physicalHeight / 2), radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
