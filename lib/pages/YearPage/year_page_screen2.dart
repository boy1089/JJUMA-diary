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
// import 'package:vector_math/vector_math.dart' as vector;
// import 'package:vector_math/vector_math_64.dart';
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
    List<Widget> charts = [];


    return Scaffold(
        body: Center(
      child: Consumer<YearPageStateProvider>(

        builder : (context, product, child) => SizedBox(
          width: physicalWidth,
          height: physicalWidth,
          child: Stack(
              children: List.generate(3, (index) {
            int year = DateTime.now().year - index;
            if (product.expandedYear == null)
              return YearChart(year: year, radius: 1 - index * 0.1, isExpanded :false);

            if (product.expandedYear == year)
              return YearChart(year: year, radius: 1 - index * 0.1, isExpanded : true);
            return YearChart(year: year, radius: year<product.expandedYear!?0:3, isExpanded :false);
          })),
        ),
      ),
    ));
  }
}

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

  @override
  Widget build(BuildContext context) {
    return Consumer<YearPageStateProvider>(
      builder: (context, product, child) => Stack(
          alignment: Alignment.center,
          children: List.generate(365, (index) {
            double day = index.toDouble();
            double week = day / 7.ceil();
            double weekday = day % 7;

            double radius = (weekday + 1) / 8 * 1.2;
            double angle = week / 52 * 2 * pi;

            if (!widget.isExpanded) {
              radius = widget.radius;
              angle = day / 365 * 2 * pi;
            }

            double xLocation = radius * cos(angle);
            double yLocation = radius * sin(angle);

            return AnimatedAlign(
                duration: Duration(milliseconds: 1000),
                curve: Curves.easeOutExpo,
                alignment: Alignment(xLocation, yLocation),
                child: Container(
                    width: physicalWidth / 20,
                    height: physicalWidth / 20,
                    // color : Colors.blue.withAlpha(200),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          shape: CircleBorder(),
                          backgroundColor: Colors.blue.withAlpha(100)),
                      onPressed: () {
                        setState(() {
                          if(widget.isExpanded) {
                            product.setExpandedYear(null);
                            return;
                          }
                          product.setExpandedYear(widget.year);
                        });
                      },
                      child:
                          Container(width: physicalWidth / 15, child: Text("aa")),
                    )));
          })),
    );
  }
}
