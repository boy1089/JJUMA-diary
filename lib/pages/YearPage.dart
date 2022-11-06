import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'dart:math';
import 'package:test_location_2nd/Util/global.dart' as global;
import 'package:test_location_2nd/Util/StateProvider.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:test_location_2nd/Util/DateHandler.dart';
import 'package:test_location_2nd/PolarMonthIndicator.dart';
import 'package:intl/intl.dart';

class YearPage extends StatefulWidget {
  const YearPage({Key? key}) : super(key: key);

  @override
  State<YearPage> createState() => _YearPageState();
}

class _YearPageState extends State<YearPage> {
  int year = DateTime.now().year;
  double _angle = 0;
  bool isZoomIn = false;
  List daysInYear = [];
  int maxOfSummary = 0;
  dynamic dummy;

  var heatmapChannel = StreamController<Selected?>.broadcast();

  void updateData(year) {
    daysInYear = getDaysInBetween(
        DateTime(year), DateTime(year + 1).subtract(Duration(days: 1)));

    List<String> availableDates =
        global.summaryOfPhotoData.keys.where((element) {
      return element.contains(year.toString());
    }).toList();
    dummy = List.generate(availableDates.length, (index) {
      String date = availableDates[index];
      int days = int.parse(DateFormat("D").format(DateTime.parse(date)));
      int value = global.summaryOfPhotoData[date]! > 200
          ? 200
          : global.summaryOfPhotoData[date]!;
      return [
        days / 7.floor(),
        days % 7,
        value,
      ];
    });

    List<int> dummy3 = List<int>.generate(transpose(dummy)[0].length,
        (index) => int.parse(transpose(dummy)[2][index].toString()));
    maxOfSummary = dummy3.reduce(max);
    print("year page, dummy3 : $maxOfSummary");
  }

  _YearPageState() {
    updateData(year);
    heatmapChannel.stream.listen(
      (value) {
        var provider =
            Provider.of<NavigationIndexProvider>(context, listen: false);

        if (value == null) return;
        if (isZoomIn) return;
        print("aaa : ${value}");
        print("streaming value : ${value.values.first.first.toString()}");
        print(
            "streaming value to date : ${DateTime(year = 2022).add(Duration(days: value.values.first.first))}");
        DateTime date =
            DateTime(year = 2022).add(Duration(days: value.values.first.first));
        if (!provider.isZoomIn) return;
        provider.setNavigationIndex(2);
        provider.setDate(date);
      },
    );
  }

  double graphSize = 400;
  double topPadding = 100;

  late Map layout_yearPage = {
    'magnification': {true: 7, false: 1},
    'graphSize': {true: graphSize * 3.5, false: graphSize},
    'left': {true: -graphSize * 2.4, false: (physicalWidth - graphSize) / 2},
    'top': {true: null, false: topPadding},
    'graphCenter': {
      true: Offset(0, 0),
      false: Offset(physicalWidth / 2, graphSize / 2 + topPadding)
    },
  };

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<NavigationIndexProvider>(context, listen: false);
    var isZoomIn =
        Provider.of<NavigationIndexProvider>(context, listen: true).isZoomIn;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                AllowMultipleGestureRecognizer:
                    GestureRecognizerFactoryWithHandlers<
                            AllowMultipleGestureRecognizer>(
                        () => AllowMultipleGestureRecognizer(),
                        (AllowMultipleGestureRecognizer instance) {
                  instance.onTapDown = (details) {
                    print(global.indexForZoomInImage);
                    if (isZoomIn) return;

                    Offset tapPosition = calculateTapPositionRefCenter(
                        details, 0, layout_yearPage);
                    double angleZoomIn = calculateTapAngle(tapPosition, 0, 0);

                    // if (tapPosition.dy < -200) return;
                    //if editing text, doesn't zoom in.
                    setState(() {
                      provider.setZoomInState(true);
                      _angle = angleZoomIn;
                      provider.setZoomInRotationAngle(_angle);
                      isZoomIn = true;
                    });
                  };
                }),
                AllowMultipleGestureRecognizer2:
                    GestureRecognizerFactoryWithHandlers<
                        AllowMultipleGestureRecognizer2>(
                  () => AllowMultipleGestureRecognizer2(),
                  (AllowMultipleGestureRecognizer2 instance) {
                    instance.onUpdate = (details) {
                      _angle = isZoomIn ? _angle + details.delta.dy / 400 : 0;
                      setState(() {});
                    };
                  },
                )
              },
              child: Stack(
                  alignment: isZoomIn ? Alignment.center : Alignment.topCenter,
                  children: [
                    AnimatedPositioned(
                      duration: Duration(milliseconds: global.animationTime),
                      width:
                          layout_yearPage['graphSize']?[isZoomIn]?.toDouble(),
                      height:
                          layout_yearPage['graphSize']?[isZoomIn]?.toDouble(),
                      left: layout_yearPage['left']?[isZoomIn]?.toDouble(),
                      top: layout_yearPage['top']?[isZoomIn]?.toDouble(),
                      curve: Curves.fastOutSlowIn,
                      // child: Transform.rotate(
                      child: AnimatedRotation(
                        // angle: isZoomIn ? _angle * 2 * pi : 0,
                        turns: isZoomIn ? _angle : 0,
                        duration:
                            Duration(milliseconds: global.animationTime - 100),
                        child: Stack(alignment: Alignment.center, children: [
                          PolarMonthIndicators().build(context),
                          Chart(
                            data: dummy,
                            // selections : Selection(),
                            elements: [
                              PointElement(
                                size: SizeAttr(
                                  variable: 'value',
                                  values: !isZoomIn
                                      ? [1, maxOfSummary / 5]
                                      : [3.5, maxOfSummary / 10 * 3],
                                ),
                                color: ColorAttr(
                                  variable: 'value',
                                  values: [
                                    // Colors.white24.withAlpha(200),
                                    global.kMainColor_warm.withAlpha(255),
                                    global.kMainColor_warm.withAlpha(255),
                                  ],
                                ),
                                selectionChannel: heatmapChannel,
                              ),
                            ],
                            variables: {
                              'week': Variable(
                                accessor: (List datum) => datum[0] as num,
                                scale:
                                    LinearScale(min: 0, max: 52, tickCount: 10),
                              ),
                              'day': Variable(
                                accessor: (List datum) => datum[1] as num,
                              ),
                              'value': Variable(
                                accessor: (List datum) => datum[2] as num,
                              ),
                            },
                            selections: {
                              'tap': PointSelection(
                                nearest: false,
                                testRadius: isZoomIn ? 5 : 0,
                              )
                            },
                            coord: PolarCoord()..radiusRange = [0.4, 1],
                            tooltip: TooltipGuide(
                              anchor: (_) => Offset.zero,
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ])),
          Positioned(
            width: layout_yearPage['graphSize'][false].toDouble(),
            height: layout_yearPage['graphSize'][false].toDouble(),
            top: layout_yearPage['top'][false].toDouble(),
            child: Offstage(
              offstage: isZoomIn ? true : false,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                IconButton(
                  onPressed: () {
                    year = year - 1;
                    updateData(year);
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.arrow_left,
                    color: global.kMainColor_cool,
                  ),
                ),
                Text(
                  "$year",
                  style: TextStyle(fontSize: 30),
                ),
                IconButton(
                    onPressed: () {
                      year = year + 1;
                      updateData(year);
                      setState(() {});
                    },
                    icon: Icon(Icons.arrow_right),
                    color: global.kMainColor_cool),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
