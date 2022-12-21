import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lateDiary/Data/info_from_file.dart';
import 'package:lateDiary/StateProvider/year_page_state_provider.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:extended_image/extended_image.dart';
import 'dart:io';

import 'package:lateDiary/pages/YearPage/year_page_screen2.dart';
import '../DayPage/model/event.dart';
import '../DayPage/widgets/photo_card.dart';
import 'scatters.dart';
import 'package:badges/badges.dart';

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

class _YearChartState extends State<YearChart> with TickerProviderStateMixin {
  int year;
  var data;
  bool isExpanded;
  double radius;
  _YearChartState(this.product, this.year, this.isExpanded, this.radius) {
    print("debugging.. ${year}");
  }
  YearPageStateProvider product;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: true);

  late final Animation<AlignmentGeometry> _animation = Tween<AlignmentGeometry>(
    begin: Alignment.bottomLeft,
    end: Alignment.center,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.decelerate,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
          alignment: Alignment.center,
          children: [...List.generate(product.dataForChart2_modified[year].length,
                  (index) {
                var data = product.dataForChart2_modified[year];
                isExpanded = (product.expandedYear == year);
                double left = isExpanded ? data[index][0] : data[index][2];
                double top = isExpanded ? data[index][1] : data[index][3];
                String date = data[index][9];
                bool hasNote = product.dataManager.noteForChart2[year.toString()]
                ?[date] !=
                    null;
                if (hasNote) print("hasNote : $hasNote");

                int? indexOfFavoriteImage = product.dataManager.indexOfFavoriteImages[year.toString()]?[date];


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
                              product.setExpandedYear(year);
                              product.setPhotoViewScale(1);
                            });
                            return;
                          }
                          if (widget.isExpanded) {
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
                                  )),
                            );
                          }
                        },
                        child: Hero(
                            tag: "${year.toString()}${index}",
                            child: indexOfFavoriteImage !=null
                                ? Badge(
                              padding: EdgeInsets.all(3.0),
                              position: BadgePosition(end: -3.0, top: -3.0),
                              showBadge: hasNote,
                              child: Scatter.fromType(
                                  entries.elementAt(indexOfFavoriteImage).key,
                                  size: size,
                                  color: color,
                                  type: scatterType.image),
                            )
                                : Scatter.fromType("aa",
                                size: size,
                                color: color,
                                type: scatterType.defaultRect))));
              }),


            AnimatedPositioned(
                duration: Duration(milliseconds: 1000),
                left:
                (product.expandedYear == year)
                    ?sizeOfChart.width / 2 - 28
                    :sizeOfChart.width / 2 - 18,

                top: (product.expandedYear == year)
                    ? sizeOfChart.height / 2 - 18
                    : (2 - radius) / 2 * sizeOfChart.height / 2 -14,
                curve: Curves.easeOutExpo,
                child: Offstage(
                    offstage: (product.expandedYear != null) && (!isExpanded),
                    child: Text("$year", style: TextStyle(fontSize: isExpanded? 24:16),)))
          ]

      ),
    );
  }
}

class photoSpread extends StatelessWidget {
  var entries;
  var position;
  var sortedEntries;
  photoSpread({Key? key, required this.entries, required this.position})
      : super(key: key) {
    sortEntries();
  }

  void sortEntries() async {
    List events = [];
    DateTime datetime_prev = entries.elementAt(0).value.datetime;
    DateTime datetime_after = DateTime(2022);

    List event = [];
    event.add(entries.elementAt(0));
    for (int i = 1; i < entries.length; i++) {
      datetime_after = entries.elementAt(i).value.datetime;
      if ((datetime_after.difference(datetime_prev)) > Duration(hours: 1)) {
        events.add(event);
        event = [entries.elementAt(i)];
        datetime_prev = datetime_after;
        continue;
      }
      event.add(entries.elementAt(i));
    }
    if (event.isNotEmpty) events.add(event);
    sortedEntries = events;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: List.generate(sortedEntries.length, (index) {
      return Positioned(
          left: position.dx -
              50 +
              cos(2 * pi / sortedEntries.length * index) * physicalWidth / 4,
          top: position.dy -
              50 +
              sin(2 * pi / sortedEntries.length * index) * physicalWidth / 4,
          child: SizedBox(
            width: physicalWidth / 4,
            height: physicalWidth / 4,
            child: ExtendedImage.file(
              File(sortedEntries.elementAt(index)[0].key),
              compressionRatio: 0.1,
            ),
          ));
    }));
  }
}
