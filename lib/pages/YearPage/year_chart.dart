import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lateDiary/Data/info_from_file.dart';
import 'package:lateDiary/StateProvider/year_page_state_provider.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:extended_image/extended_image.dart';
import 'package:lateDiary/pages/YearPage/widgets/photo_card.dart';
import 'dart:io';

import 'package:lateDiary/pages/YearPage/year_page_screen.dart';
import '../event.dart';
import 'scatters.dart';
import 'package:badges/badges.dart';

class YearChart extends StatefulWidget {
  YearChart({
    Key? key,
    required this.year,
    required this.radius,
    required this.product,
  }) : super(key: key);

  double radius;
  int year;
  YearPageStateProvider product;
  @override
  State<YearChart> createState() => _YearChartState(product, year, radius);
}

class _YearChartState extends State<YearChart> {
  int year;
  var data;
  bool isExpanded = false;
  double radius;

  Map locationOfYearText = {};

  _YearChartState(this.product, this.year, this.radius) {
    print("building year chart.. ${year}");
    locationOfYearText = {
      true: {
        "left": sizeOfChart.width / 2 - 28,
        'top': sizeOfChart.height / 2 - 16,
      },
      false: {
        "left": sizeOfChart.width / 2 - 14,
        'top': (2 - radius) / 2 * sizeOfChart.height / 2 - 14,
      }
    };
  }
  YearPageStateProvider product;

  @override
  Widget build(BuildContext context) {
    print("build year chart : ${year}");
    isExpanded = product.expandedYear == year;
    return Center(
      child: Stack(alignment: Alignment.center, children: [
        ...List.generate(product.dataForChart2_modified[year].length, (index) {
          var data = product.dataForChart2_modified[year];
          double left = isExpanded ? data[index][0] : data[index][2];
          double top = isExpanded ? data[index][1] : data[index][3];
          String date = data[index][9];

          int? indexOfFavoriteImage =
              product.dataManager.indexOfFavoriteImages[year.toString()]?[date];

          if ((product.expandedYear != null) && (!isExpanded)) {
            left = data[index][4];
            top = data[index][5];
          }

          double size = data[index][6];
          Color color = data[index][7];
          color = color.withAlpha(year == product.highlightedYear ? 240 : 100);

          List entries = data[index][8];

          return AnimatedPositioned(
              duration: Duration(milliseconds: 1000),
              curve: Curves.easeOutExpo,
              left: left,
              top: top,
              child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onDoubleTap: () {
                    product.setExpandedYear(null);
                    setState(() {});
                  },
                  onTapDown: (detail) {
                    if ((product.expandedYear != year))
                      product.setHighlightedYear(year);
                  },

                  onTapCancel: () {
                    product.setHighlightedYear(null);
                  },

                  onTapUp: (detail) {
                    product.setHighlightedYear(null);
                    if (!isExpanded) {
                      product.setExpandedYear(year);
                      product.setPhotoViewScale(1);
                      return;
                    }
                    if (isExpanded) {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                            transitionDuration: Duration(milliseconds: 500),
                            pageBuilder: (_, __, ___) => PhotoCard(
                                  tag: "${year.toString()}${index}",
                                  isMagnified: true,
                                  event: Event(
                                    images: Map.fromIterable(entries,
                                        key: (item) => item.key,
                                        value: (item) => item.value),
                                    // {for(MapEntry<dynamic, InfoFromFile> entry in entries)}),
                                    note: "",
                                  ),
                              indexOfFavoriteImage : indexOfFavoriteImage,
                                )),
                      );
                    }
                  },
                  child: Hero(
                      tag: "${year.toString()}${index}",
                      child: indexOfFavoriteImage != null
                          ? Scatter.fromType(
                              entries.elementAt(indexOfFavoriteImage).key,
                              size: size > 20.0 ? size : 20.0,
                              color: color,
                              type: scatterType.image)
                          : Scatter.fromType("aa",
                              size: size,
                              color: color,
                              type: scatterType.defaultRect))));
        }),
        AnimatedPositioned(
            duration: Duration(milliseconds: 1000),
            left: locationOfYearText[isExpanded]['left'],
            top: locationOfYearText[isExpanded]['top'],
            curve: Curves.easeOutExpo,
            child: Offstage(
                offstage: (!isExpanded),
                child: Text(
                  "$year",
                  style: TextStyle(fontSize: isExpanded ? 24 : 12,
                  fontWeight: year==product.highlightedYear? FontWeight.w800:FontWeight.w400),
                )))
      ]),
    );
  }
}
