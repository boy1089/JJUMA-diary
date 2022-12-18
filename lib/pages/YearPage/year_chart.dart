import 'package:flutter/material.dart';
import 'package:lateDiary/StateProvider/year_page_state_provider.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:extended_image/extended_image.dart';
import 'dart:io';


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
                    child: Container(

                      // width: (product.expandedYear == year) &&(product.photoViewScale! > 2)
                      //     ? size/ product.photoViewScale!
                      //     : size ,
                      // height: (product.expandedYear == year) &&(product.photoViewScale! > 2)
                      //     ? size/ product.photoViewScale!
                      //     : size ,

                      width : size,
                      height : size,

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

