import 'dart:async';
import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:lateDiary/Data/data_manager_interface.dart';
import 'package:lateDiary/Data/info_from_file.dart';
import 'package:lateDiary/StateProvider/day_page_state_provider.dart';
import 'package:lateDiary/app.dart';
import 'package:lateDiary/pages/DayPage/widgets/clickable_photo_card.dart';
import 'package:lateDiary/pages/DayPage/widgets/photo_card.dart';
import 'package:lateDiary/pages/setting_page.dart';
import 'package:matrix2d/matrix2d.dart';
import 'package:photo_view/photo_view.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';
import '../../Location/coordinate.dart';
import '../../Util/DateHandler.dart';
import '../DayPage/model/event.dart';
import 'year_page_view.dart';
import 'package:provider/provider.dart';

import 'package:lateDiary/StateProvider/year_page_state_provider.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:go_router/go_router.dart';
import 'year_page_view_level1.dart';
import 'package:lateDiary/Util/Util.dart';

import 'package:photo_view/photo_view.dart';
import 'dart:math';

class YearPageScreen2 extends StatefulWidget {
  YearPageScreen2({Key? key}) : super(key: key);

  @override
  State<YearPageScreen2> createState() => _YearPageScreen2State();
}

class _YearPageScreen2State extends State<YearPageScreen2> {
  int? expandedYear = null;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<YearPageStateProvider>(
        builder: (context, product, child) => PhotoView.customChild(
          // customSize: Size(physicalWidth+100, physicalHeight),
          minScale: 1.0,
          onScaleEnd: (context, value, a) {
            product.photoViewScale = a.scale ?? 1;
            if (product.photoViewScale! < 1) {
              product.setPhotoViewScale(1);
              product.setExpandedYear(null);
            }
            ;
            setState(() {});
          },
          child: SizedBox(
            width: physicalWidth,
            height: physicalWidth,
            child: Stack(
                alignment: Alignment.center,
                children: List.generate(product.dataForChart2.length, (index) {
                  int year = product.dataForChart2.keys.elementAt(index);

                  if (product.expandedYear == null) {
                    return YearChart(
                        year: year,
                        radius: 1 - index * 0.1,
                        isExpanded: false,
                        product: product);
                  }
                  if (product.expandedYear == year)
                    return YearChart(
                        year: year,
                        radius: 1 - index * 0.1,
                        isExpanded: true,
                        product: product);

                  return SizedBox();
                })),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var a = DataManagerInterface(global.kOs);
          await a.init();
        },
      ),
    );
  }
}

List positionExpanded = List.generate(366, (index) {
  double day = index.toDouble();
  double week = day / 7.ceil();
  double weekday = day % 7;
  double radius = (weekday + 3) / 8 * 1.2;
  double angle = week / 52 * 2 * pi;

  double xLocation = radius * cos(angle - pi / 2);
  double yLocation = radius * sin(angle - pi / 2);
  return [xLocation, yLocation];
});

List positionNotExpanded = List.generate(366, (index) {
  double day = index.toDouble();
  double week = day / 7.ceil();
  double weekday = day % 7;
  double angle = day / 365 * 2 * pi;
  double xLocation = 1 * cos(angle - pi / 2);
  double yLocation = 1 * sin(angle - pi / 2);
  return [xLocation, yLocation];
});

class YearChart extends StatefulWidget {
  YearChart({
    Key? key,
    required this.year,
    required this.radius,
    required this.isExpanded,
    required this.product,
  }) : super(key: key);

  double radius;
  int year;
  bool isExpanded;
  YearPageStateProvider product;
  @override
  State<YearChart> createState() => _YearChartState(product, year, isExpanded, radius);
}

class _YearChartState extends State<YearChart> {
  List dataForNotExpanded = [];
  List dataForExpanded = [];
  int year;
  var data;
  bool isExpanded;
  double radius;
  _YearChartState(this.product, this.year, this.isExpanded, this.radius) {
    print("debugging.. ${year}");

    // data = product.dataForChart2[year];
    // dataForExpanded = List.generate(data.length, (index){
    //   String date = data.keys.elementAt(index);
    //   DateTime datetime = DateTime(year, int.parse(date.substring(4, 6)),
    //       int.parse(date.substring(6, 8)));
    //   int indexOfDate = datetime.difference(DateTime(year)).inDays;
    //
    //   double xLocation =  positionExpanded[indexOfDate][0];
    //
    //   double yLocation = positionExpanded[indexOfDate][1];
    //
    //   yLocation = yLocation + 0.5;
    //
    //   int numberOfImages = data[date]?[0].length ?? 1;
    //   Coordinate? coordinate = data[date]?[1];
    //   Color color = coordinate == null
    //       ? Colors.grey.withAlpha(150)
    //       : Color.fromARGB(
    //     100,
    //     // 0,
    //     255 -
    //         ((coordinate.longitude ??
    //             127 - product.averageCoordinate!.longitude!) *
    //             200)
    //             .toInt(),
    //     150,
    //     ((coordinate.longitude ??
    //         127 - product.averageCoordinate!.longitude!)
    //         .abs() *
    //         200)
    //         .toInt(),
    //   );
    //   double size = 20;
    //   size = log(numberOfImages) * 5;
    //   List entries = data[date]![0];
    //   double left = xLocation * (physicalWidth) / 2 +
    //       (physicalWidth) / 2 -
    //       size / 2;
    //   double top = yLocation * physicalWidth / 2 +
    //       physicalWidth / 2 -
    //       size / 2;
    //   // return [xLocation, yLocation, size, color, entries];
    //   return [left, top, size, color, entries];
    // });
    // dataForNotExpanded = List.generate(data.length, (index) {
    //   String date = data.keys.elementAt(index);
    //   DateTime datetime = DateTime(year, int.parse(date.substring(4, 6)),
    //       int.parse(date.substring(6, 8)));
    //   int indexOfDate = datetime.difference(DateTime(year)).inDays;
    //
    //   double xLocation =
    //       positionNotExpanded[indexOfDate][0].toDouble() * radius;
    //   double yLocation =
    //        positionNotExpanded[indexOfDate][1].toDouble() * radius;
    //   yLocation = yLocation + 0.5;
    //
    //   int numberOfImages = data[date]?[0].length ?? 1;
    //   Coordinate? coordinate = data[date]?[1];
    //   Color color = coordinate == null
    //       ? Colors.grey.withAlpha(150)
    //       : Color.fromARGB(
    //           100,
    //           // 0,
    //           255 -
    //               ((coordinate.longitude ??
    //                           127 - product.averageCoordinate!.longitude!) *
    //                       200)
    //                   .toInt(),
    //           150,
    //           ((coordinate.longitude ??
    //                           127 - product.averageCoordinate!.longitude!)
    //                       .abs() *
    //                   200)
    //               .toInt(),
    //         );
    //
    //   double size = 20;
    //   size = log(numberOfImages) * 5;
    //   List entries = data[date]![0];
    //   double left = xLocation * (physicalWidth) / 2 +
    //       (physicalWidth) / 2 -
    //       size / 2;
    //   double top = yLocation * physicalWidth / 2 +
    //       physicalWidth / 2 -
    //       size / 2;
    //   // return [xLocation, yLocation, size, color, entries];
    //   return [left, top, size, color, entries];
    // });

  }
  YearPageStateProvider product;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
          alignment: Alignment.center,
          children: List.generate(product.dataForChart2_modified[year].length,
              (index) {
            var data = product.dataForChart2_modified[year];
            double left = isExpanded? data[index][0]: data[index][2];
            double top = isExpanded? data[index][1]:data[index][3];
            double size = data[index][4];
            Color color = data[index][5];
            List entries = data[index][6];

            return AnimatedPositioned(
                duration: Duration(milliseconds: 1000),
                curve: Curves.easeOutExpo,
                left: left,
                top: top,
                child: Container(
                  width: (product.expandedYear != null) &&
                          (product.photoViewScale! < 2)
                      ? size / product.photoViewScale!
                      : size,
                  height: (product.expandedYear != null) &&
                          (product.photoViewScale! < 2)
                      ? size / product.photoViewScale!
                      : size,
                  decoration:
                      ShapeDecoration(shape: const Border(), color: color),
                  child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onDoubleTap: () {
                        product.setExpandedYear(null);
                        setState(() {});
                      },
                      onTap: () {
                        if (!widget.isExpanded) {
                          setState(() {
                            product.setExpandedYear(widget.year);
                            product.setPhotoViewScale(1);
                          });
                          return;
                        }
                      },
                      child :  SizedBox(width: 100, height: 100))
                      // child: !(product.expandedYear == null) &&
                      //         (product.photoViewScale! > 2)
                      //     ? ExtendedImage.file(
                      //         File(entries.elementAt(0).key),
                      //         compressionRatio: 0.1,
                      //         cacheRawData: true,
                      //       )
                      //     : SizedBox(width: 100, height: 100)),
                ));
          })),
    );
  }
}
