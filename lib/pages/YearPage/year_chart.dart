import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lateDiary/StateProvider/year_page_state_provider.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:extended_image/extended_image.dart';
import 'dart:io';

import 'package:lateDiary/pages/YearPage/year_page_screen2.dart';
import 'scatters.dart';

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
          children: [
            AnimatedPositioned(
                duration: Duration(milliseconds: 1000),
                left: sizeOfChart.width / 2 - 16,
                top: (product.expandedYear == year)
                    ? sizeOfChart.height / 2 - 8
                    : (2 - radius) / 2 * sizeOfChart.height / 2 - 16,
                curve: Curves.easeOutExpo,
                child: Offstage(
                    offstage: (product.expandedYear != null) && (!isExpanded),
                    child: Text("$year")))
          ]..addAll(List.generate(product.dataForChart2_modified[year].length,
                (index) {
              var data = product.dataForChart2_modified[year];
              isExpanded = (product.expandedYear == year);
              double left = isExpanded ? data[index][0] : data[index][2];
              double top = isExpanded ? data[index][1] : data[index][3];

              if ((product.expandedYear != null) && (!isExpanded)) {
                left = data[index][4];
                top = data[index][5];
              }

              double size = data[index][6];
              Color color = data[index][7];
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
                      onTapUp: (detail) {
                        if (!widget.isExpanded) {
                          setState(() {
                            product.setExpandedYear(widget.year);
                            product.setPhotoViewScale(1);
                          });
                          return;
                        }
                        print(
                            "${detail.localPosition}, ${detail.globalPosition}");
                        if (widget.isExpanded) {
                          showDialog(
                              context: context,
                              builder: (context) => photoSpread(
                                  entries: entries,
                                  position: detail.globalPosition));
                        }
                      },
                      child: Scatter.fromType(size: size,color: color,type : scatterType.defaultRect)
                  ));

            }))),
    );
  }
}

class photoSpread extends StatelessWidget {
  var entries;
  var position;
  photoSpread({Key? key, required this.entries, required this.position})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: List.generate(entries.length, (index) {
      return Positioned(
          left: position.dx + cos(2 * pi / entries.length * index) * 100,
          top: position.dy + sin(2 * pi / entries.length * index) * 100,
          child: SizedBox(
            width: 100,
            height: 100,
            child: ExtendedImage.file(
              File(entries.elementAt(index).key),
              compressionRatio: 0.1,
            ),
          ));
    }));
  }
}
