import 'package:flutter/material.dart';
import 'package:matrix2d/matrix2d.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:lateDiary/Util/DateHandler.dart';
import 'dart:math' as math;

class CirclePage extends StatefulWidget {
  const CirclePage({Key? key}) : super(key: key);

  @override
  State<CirclePage> createState() => _CirclePageState();
}

class _CirclePageState extends State<CirclePage> {
  Map numberOfPhotosInYear = {};
  List<DateTime> datesOfYear = [];
  int maxNumberOfPhoto = 100;

  _CirclePageState() {
    numberOfPhotosInYear = calculateNumberOfPhotoAll(global.summaryOfPhotoData);
    print(numberOfPhotosInYear);
  }

  Map calculateNumberOfPhotoAll(Map summaryOfPhotoData) {
    List years = List.generate(DateTime.now().year - global.startYear,
        (index) => (global.startYear + index).toString()).toList();
    Map result = {};
    for (int i = 0; i < years.length; i++) {
      String year = years[i];
      result[year] = calculateNumberOfPhoto(summaryOfPhotoData, year);
    }
    maxNumberOfPhoto = result.values.elementAt(0);
    return result;
  }

  int calculateNumberOfPhoto(Map summaryOfPhotoData, year) {
    int numberOfPhotoInYear = 0;
    for (int i = 5; i < summaryOfPhotoData.length; i++) {
      String key = summaryOfPhotoData.keys.elementAt(i);
      if (key.contains(year)) {
        numberOfPhotoInYear += int.parse(summaryOfPhotoData[key].toString());
      }
    }
    return numberOfPhotoInYear;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: global.kBackGroundColor,
        width: physicalWidth,
        height: physicalHeight,
        child:
            CustomPaint(foregroundPainter: LinePainter(numberOfPhotosInYear)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print(numberOfPhotosInYear);
          print(maxNumberOfPhoto);
        },
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  Map numberOfPhotoInYear;
  LinePainter(this.numberOfPhotoInYear) {}

  @override
  void paint(Canvas canvas, Size size) {
    double radius = physicalWidth / 2 - 50;
    final paint = Paint()
      ..color = Colors.blue.withAlpha(200)
      ..strokeWidth = 50
      ..style = PaintingStyle.stroke
      ..shader = SweepGradient(
              // colors: [Colors.blue, Colors.red, Colors.blue, Colors.red],
              colors: List.generate(
                      numberOfPhotoInYear.length,
                      (index) => Color.lerp(Colors.blue, Colors.red,
                          numberOfPhotoInYear.values.elementAt(index) / 5000)!)
                  .toList())
          .createShader(Rect.fromCircle(
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
