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
      body: Center(
        child: Consumer<YearPageStateProvider>(
          builder: (context, product, child) => SizedBox(
            width: physicalWidth,
            height: physicalWidth * 1.4,
            child: Stack(
                alignment: Alignment.center,
                children: List.generate(product.dataForChart2.length, (index) {
                  int year = product.dataForChart2.keys.elementAt(index);
                  if (product.expandedYear == null) {
                    return YearChart(
                        year: year, radius: 1 - index * 0.1, isExpanded: false);
                  }
                  if (product.expandedYear == year)
                    return YearChart(
                        year: year, radius: 1 - index * 0.1, isExpanded: true);
                  // return YearChart(
                  //     year: year,
                  //     radius: year < product.expandedYear! ? 0 : 3,
                  //     isExpanded: false);
                  return SizedBox();
                })),
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     var a = Provider.of<YearPageStateProvider>(context, listen: false);
      //     // a.updateData();
      //     // print(a.dataManager.infoFromFiles);
      //     // a.dataForChart2.forEach((key, value) {print("${value[1]}");});
      //   },
      // ),
    );
  }
}

List positionExpanded = List.generate(366, (index) {
  double day = index.toDouble();
  double week = day / 7.ceil();
  double weekday = day % 7;
  double radius = (weekday + 1) / 8 * 1.2;
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
  }) : super(key: key);

  double radius;
  int year;
  bool isExpanded;
  @override
  State<YearChart> createState() => _YearChartState();
}

class _YearChartState extends State<YearChart> {
  double photoViewScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Consumer<YearPageStateProvider>(
      builder: (context, product, child) => PhotoView.customChild(
        minScale: 1.0,
        onScaleEnd: (context, value, a) {
          photoViewScale = a.scale ?? 1;
          if (photoViewScale < 1) photoViewScale = 1;
          setState(() {});
          print("$value, $a");
        },
        child: Stack(
            alignment: Alignment.center,
            // clipBehavior: Clip.none,
            children: List.generate(product.dataForChart2[widget.year]!.length,
                (index) {
              // double day = index.toDouble();
              // String date = formatDate(
              //     DateTime(widget.year).add(Duration(days: day.toInt())));
              String date =
                  product.dataForChart2[widget.year]!.keys.elementAt(index);
              DateTime datetime = DateTime(
                  widget.year,
                  int.parse(date.substring(4, 6)),
                  int.parse(date.substring(6, 8)));
              int indexOfDate =
                  datetime.difference(DateTime(widget.year)).inDays;

              double xLocation = widget.isExpanded
                  ? positionExpanded[indexOfDate][0]
                  : positionNotExpanded[indexOfDate][0].toDouble() *
                      widget.radius;
              double yLocation = widget.isExpanded
                  ? positionExpanded[indexOfDate][1]
                  : positionNotExpanded[indexOfDate][1].toDouble() *
                      widget.radius;

              // double xLocation = widget.isExpanded? positionExpanded[index][0] : positionNotExpanded[index][0].toDouble();
              // double yLocation = widget.isExpanded? positionExpanded[index][1] : positionNotExpanded[index][1].toDouble();
              int numberOfImages =
                  product.dataForChart2[widget.year]?[date]?[0].length ?? 1;
              Coordinate? coordinate =
                  product.dataForChart2[widget.year]?[date]?[1];
              // int numberOfImages = index>50? 10:1;
              // if (numberOfImages != 1) print(numberOfImages);
              Color color = coordinate == null
                  ? Colors.grey.withAlpha(150)
                  : Color.fromARGB(
                      100,
                      // 0,
                      255 -
                          ((coordinate.longitude ??
                                      127 -
                                          product
                                              .averageCoordinate!.longitude!) *
                                  200)
                              .toInt(),
                      150,
                      ((coordinate.longitude ??
                                      127 -
                                          product.averageCoordinate!.longitude!)
                                  .abs() *
                              200)
                          .toInt(),
                    );
              double size = 20;
              size = log(numberOfImages) * 5 / photoViewScale;
              List entries = product.dataForChart2[widget.year]![date]![0];
              // return AnimatedAlign(
              return AnimatedPositioned(
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.easeOutExpo,
                  left: xLocation * physicalWidth / 2 +
                      physicalWidth / 2 -
                      size / 2,
                  top: yLocation * physicalWidth / 2 +
                      physicalWidth / 2 -
                      size / 2,

                  // alignment: Alignment(xLocation, yLocation),
                  child: Container(
                    width: photoViewScale<2?size : size*5,
                    height: photoViewScale<2?size: size*5,
                    decoration:
                        // ShapeDecoration(shape: const CircleBorder(), color: color),
                        ShapeDecoration(shape: const Border(), color: color),
                    child: GestureDetector(
                        onDoubleTap: () {
                          // showDialog(context: context, builder: (context)=>SimpleDialog(
                          //   children: [Text("aaa")],
                          // ));
                          product.setExpandedYear(null);
                          setState(() {});
                        },
                        onTap: () {
                          if (!widget.isExpanded) {
                            print("tap");
                            setState(() {
                              product.setExpandedYear(widget.year);
                            });
                            return;
                          }
                          showDialog(
                              context: context,
                              builder: (a) {
                                return SimpleDialog(
                                  children: [
                                    SingleChildScrollView(
                                        child: Column(
                                            children: List.generate(
                                                entries.length,
                                                (index) => ExtendedImage.file(
                                                      File(entries
                                                          .elementAt(index)
                                                          .key),
                                                      compressionRatio: 0.02,
                                                    ))))
                                  ],
                                );
                              });
                        },
                        child: photoViewScale > 2
                            ? ExtendedImage.file(
                                File(entries.elementAt(0).key),
                                compressionRatio: 0.1,
                              )
                            : SizedBox()),
                  ));
            })),
      ),
    );
  }
}
