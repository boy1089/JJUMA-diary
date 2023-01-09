import 'package:flutter/material.dart';
import 'package:jjuma.d/StateProvider/year_page_state_provider.dart';
import 'package:jjuma.d/pages/YearPage/widgets/photo_card.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import '../../Util/Util.dart';
import '../event.dart';
import 'scatters.dart';
import 'package:jjuma.d/Util/global.dart' as global;

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
  YearPageStateProvider product;

  _YearChartState(this.product, this.year, this.radius);

  @override
  Widget build(BuildContext context) {
    // print("build year chart : ${year}");
    isExpanded = product.expandedYear == year;
    return Center(
      child: Stack(alignment: Alignment.center, children: [
        ...List.generate(product.dataForChart2_modified[year].length, (index) {
          var data = product.dataForChart2_modified[year];
          double left = isExpanded ? data[index][0] : data[index][2];
          double top = isExpanded ? data[index][1] : data[index][3];
          String date = data[index][9];

          String? filenameOfFavoriteImage = product
              .dataManager.filenameOfFavoriteImages[year.toString()]?[date];

          if ((product.expandedYear != null) && (!isExpanded)) {
            left = data[index][4];
            top = data[index][5];
          }

          double size = data[index][6];
          Color color = data[index][7];
          color = color.withAlpha(year == product.highlightedYear ? 240 : 150);

          List entries = data[index][8];

          return AnimatedPositioned(
              duration: const Duration(milliseconds: 1000),
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
                    if ((product.expandedYear != year)) {
                      product.setHighlightedYear(year);
                    }
                  },
                  onTapCancel: () {
                    product.setHighlightedYear(null);
                  },
                  onTapUp: (detail) => onTapUp(
                      isExpanded, index, entries, filenameOfFavoriteImage),
                  child: Hero(
                      tag: "${year.toString()}$index",
                      child: filenameOfFavoriteImage != null
                          ? Scatter.fromType(filenameOfFavoriteImage,
                              size: size > 20.0 ? size : 20.0,
                              color: color,
                              type: ScatterType.image)
                          : Scatter.fromType("aa",
                              size: size,
                              color: color,
                              type: ScatterType.defaultRect))));
        }),
      ]),
    );
  }

  onTapUp(isExpanded, index, entries, filenameOfFavoriteImage) {
    product.setHighlightedYear(null);
    if (!isExpanded) {
      product.setExpandedYear(year);
      return;
    }
    if (isExpanded) {
      switch (global.kOs) {
        case ("android"):
          {
            Navigator.push(
              context,
              PageRouteBuilder(
                  transitionDuration: Duration(milliseconds: 700),
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
                        filenameOfFavoriteImage: filenameOfFavoriteImage,
                      )),
            );
          }
          break;
        case ("ios"):
          {
            Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: Duration(milliseconds: 700),
                  pageBuilder: (_, __, ___) => PhotoCard(
                    tag: "${year.toString()}${index}",
                    isMagnified: true,
                    event: Event(
                      images: Map.fromIterable(entries,
                          key: (item) => item.key, value: (item) => item.value),
                      // {for(MapEntry<dynamic, InfoFromFile> entry in entries)}),
                      note: "",
                    ),
                    filenameOfFavoriteImage: filenameOfFavoriteImage,
                  ),
                ));
          }
      }
    }
  }
}
