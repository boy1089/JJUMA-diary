import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'dart:math' as math;
import 'package:test_location_2nd/Util/global.dart' as global;
import 'package:test_location_2nd/Util/StateProvider.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:test_location_2nd/Util/DateHandler.dart';
import 'package:test_location_2nd/PolarMonthIndicator.dart';
import 'package:intl/intl.dart';
import 'package:test_location_2nd/Location/Coordinate.dart';
import 'package:test_location_2nd/Data/DataManager.dart';
import 'dart:developer';

class YearPage extends StatefulWidget {
  YearPage({Key? key}) : super(key: key);
  @override
  State<YearPage> createState() => _YearPageState();
}

class _YearPageState extends State<YearPage> {
  int year = DateTime.now().year;
  double _angle = 0;
  int maxOfSummary = 0;
  List<String> availableDates = [];
  dynamic dataForPlot;

  var heatmapChannel = StreamController<Selected?>.broadcast();

  _YearPageState() {
    updateData(year);
    heatmapChannel.stream.listen(
      (value) {
        var provider =
            Provider.of<NavigationIndexProvider>(context, listen: false);
        var uiStateProivder = Provider.of<UiStateProvider>(context, listen: false);

        if (value == null) return;
        if (!uiStateProivder.isZoomIn) return;
        print("aaa : ${value}");
        print("streaming value : ${value.values.first.first.toString()}");
        DateTime date = DateTime.parse(availableDates
            .elementAt(int.parse(value.values.first.first.toString())));
        if (!uiStateProivder.isZoomIn) return;
        provider.setNavigationIndex(2);
        provider.setDate(date);
      },
    );
  }

  void updateData(year) {
    availableDates = global.summaryOfPhotoData.keys.where((element) {
      return element.contains(year.toString());
    }).toList();

    dataForPlot = List.generate(52, (index) {
      return [
        index,
        1,
        10,
        0.2,
      ];
    });

    if (availableDates.length == 0) return dataForPlot;

    dataForPlot = List.generate(availableDates.length, (index) {
      String date = availableDates[index];
      int days = int.parse(DateFormat("D").format(DateTime.parse(date)));
      int value = global.summaryOfPhotoData[date]! > 200
          ? 200
          : global.summaryOfPhotoData[date]!;

      double distance = 0.1;

      if (global.summaryOfLocationData[date] == null ||
          global.summaryOfLocationData[date] == 0) {
        distance = 0.1;
      } else {
        distance = global.summaryOfLocationData[date] > 100
            ? 100
            : global.summaryOfLocationData[date];
        // print("date : $date, distance $distance");
      }
      return [
        days / 7.floor(),
        days % 7,
        value,
        distance,
      ];
    });
    List<int> dummy3 = List<int>.generate(transpose(dataForPlot)[0].length,
        (index) => int.parse(transpose(dataForPlot)[2][index].toString()));
    maxOfSummary = dummy3.reduce(math.max);
    print("year page, dummy3 : $maxOfSummary");
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
    print("yearPage built");
    var provider = Provider.of<UiStateProvider>(context, listen: true);
    var isZoomIn =
        Provider.of<UiStateProvider>(context, listen: false).isZoomIn;

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
                        provider.setZoomInRotationAngle(_angle);
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
                      // curve: Curves.fastOutSlowIn,

                      // child: Transform.rotate(
                      child: AnimatedRotation(
                        // angle: isZoomIn ? _angle * 2 * pi : 0,
                        turns: isZoomIn ? provider.zoomInAngle : 0,
                        duration:
                            Duration(milliseconds: global.animationTime - 100),
                        child: Stack(alignment: Alignment.center, children: [
                          PolarMonthIndicators().build(context),
                          Chart(
                            data: dataForPlot,
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
                                  variable: 'distance',
                                  values: [
                                    // Colors.white24.withAlpha(200),
                                    // global.kMainColor_warm.withAlpha(255),
                                    // global.kMainColor_cool,
                                    Colors.blue.withAlpha(150),
                                    Colors.red.withAlpha(150),
                                    // global.kMainColor_warm.withAlpha(255),
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
                              'distance': Variable(
                                accessor: (List datum) =>
                                    math.log(datum[3]) + 0.1 as num,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // print(dummy);
          // var a = global.summaryOfPhotoData;
          var a = global.summaryOfLocationData;
          print(a);
          Timeline.timeSync("Aa", () async {
            provider.setZoomInState(true);
            setState((){});
            await Future.delayed(Duration(seconds: 1));
            provider.setZoomInRotationAngle(_angle+0.01);
            provider.setZoomInRotationAngle(_angle+0.01);
            provider.setZoomInRotationAngle(_angle+0.01);
            provider.setZoomInRotationAngle(_angle+0.01);
            provider.setZoomInRotationAngle(_angle+0.01);

            setState((){});
            await Future.delayed(Duration(seconds: 1));
            provider.setZoomInState(false);
            setState((){});
          });
          // for (int i = 0; i < a.length; i++) {
            // print("${a.keys.elementAt(i)}, ${a.values.elementAt(i).latitude}");
            // print("${a.keys.elementAt(i)}, ${a.values.elementAt(i)}");
            // debugDumpRenderTree();
            // Timeline.timeSync("Aa", () => {
            //   provider.setZoomInState(true),
            //     provider.setZoomInState(false)
            // }
            // );
            // print('aaa');
            // Timeline.finishSync();

        },
      ),
    );
  }
}
