import 'dart:async';
import 'dart:io';
import 'dart:ui';

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
          minScale: 1.0,
          onScaleEnd: (context, value, a) {
            product.setPhotoViewScale(a.scale ?? 1);
            if (product.photoViewScale! < 1) {
              product.setPhotoViewScale(1);
              product.setExpandedYear(null);
            }
          },
          child: Container(
            width: physicalWidth,
            height: physicalWidth,
            child: Stack(
                alignment: Alignment.center,

                // children: List.generate(product.dataForChart2.length, (index) {
                children: List.generate(3, (index) {
                  int year = product.dataForChart2.keys.elementAt(index);

                  // if (product.expandedYear == null) {
                  return Container(
                    child: YearChart(
                        year: year,
                        radius: 1 - index * 0.1,
                        isExpanded: (product.expandedYear == null) ||
                                (product.expandedYear == year)
                            ? false
                            : true,
                        product: product),
                  );
                })),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // var a = DataManagerInterface(global.kOs);
          // await a.init();
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
  State<YearChart> createState() =>
      _YearChartState(product, year, isExpanded, radius);
}

class _YearChartState extends State<YearChart> {
  int year;
  var data;
  bool isExpanded;
  double radius;
  _YearChartState(this.product, this.year, this.isExpanded, this.radius) {
    print("debugging.. ${year}");
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
            isExpanded = (product.expandedYear == year);
            double left = isExpanded ? data[index][0] : data[index][2];
            double top = isExpanded ? data[index][1] : data[index][3];

            if ((product.expandedYear != null) && (!isExpanded)) {
              left = data[index][4] * 5 * (physicalWidth) / 2 +
                  (physicalWidth) / 2;
              top = data[index][5] * 5 * (physicalWidth) / 2 +
                  (physicalWidth) / 2;
              ;
            }

            double size = data[index][6];
            Color color = data[index][7];
            List entries = data[index][8];

            return AnimatedPositioned(
                duration: Duration(milliseconds: 1000),
                curve: Curves.easeOutExpo,
                left: left,
                top: top,
                child: Container(
                  width: (product.photoViewScale! < 2)
                      ? size
                      : size / product.photoViewScale!,
                  height: (product.photoViewScale! < 2)
                      ? size
                      : size / product.photoViewScale!,
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
                      // child: SizedBox(width: 100, height: 100))
                      child: (product.expandedYear == year) &&
                              (product.photoViewScale! > 2)
                          ? ExtendedImage.file(
                              File(entries.elementAt(0).key),
                              compressionRatio: 0.1,
                              cacheRawData: true,
                            )
                          : SizedBox(width: 100, height: 100)),
                ));
          })),
    );
  }
}
