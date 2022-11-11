import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'dart:math' as math;
import 'package:test_location_2nd/Util/global.dart' as global;
import 'package:test_location_2nd/Util/StateProvider.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:test_location_2nd/PolarMonthIndicator.dart';
import 'package:intl/intl.dart';
import 'package:test_location_2nd/CustomWidget/ZoomableWidgets.dart';

class YearPage extends StatefulWidget {
  int year;
  YearPage(this.year, {Key? key}) : super(key: key);
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

  _YearPageState() {}

  @override
  void initState() {
    print("year page create");
    updateData(widget.year, false);
    heatmapChannel.stream.listen(
      (value) {
        var provider =
            Provider.of<NavigationIndexProvider>(context, listen: false);
        var yearPageStateProvider =
            Provider.of<YearPageStateProvider>(context, listen: false);

        if (value == null) return;
        if (!yearPageStateProvider.isZoomIn) return;
        print("streaming value : ${value.values.first.first.toString()}");
        DateTime date = DateTime.parse(availableDates
            .elementAt(int.parse(value.values.first.first.toString())));
        if (!yearPageStateProvider.isZoomIn) return;
        provider.setNavigationIndex(2);
        provider.setDate(date);
      },
    );
    super.initState();
  }

  void updateData(year, setYear) {
    if (setYear)
      Provider.of<YearPageStateProvider>(context, listen: false).setYear(year);
    this.year = year;
    availableDates = global.summaryOfPhotoData.keys.where((element) {
      return element.contains(year.toString());
    }).toList();

    Provider.of<DayPageStateProvider>(context, listen: false)
        .setAvailableDates(availableDates);

    dataForPlot = List.generate(52, (index) {
      return [
        index,
        1,
        10,
        0.01,
      ];
    });

    if (availableDates.length == 0) return dataForPlot;

    dataForPlot = List.generate(availableDates.length, (index) {
      String date = availableDates[index];
      int days = int.parse(DateFormat("D").format(DateTime.parse(date)));
      int value = global.summaryOfPhotoData[date]! > 200
          ? 200
          : global.summaryOfPhotoData[date]!;

      double distance = 0.01;
      var temp = global.summaryOfLocationData[date];
      // print("$date, $temp");
      if (global.summaryOfLocationData[date] == null ||
          global.summaryOfLocationData[date] == 0) {
        distance = 0.01;
      } else {
        distance = global.summaryOfLocationData[date]! > 100
            ? 100
            : global.summaryOfLocationData[date]!;
        // print("date : $date, distance $distance");
      }
      return [
        days / 7.floor() + index % 3 / 4,
        (days - 2) % 7,
        value,
        distance,
      ];
    });
    List<int> dummy3 = List<int>.generate(transpose(dataForPlot)[0].length,
        (index) => int.parse(transpose(dataForPlot)[2][index].toString()));
    maxOfSummary = dummy3.reduce(math.max);
    print("year page, dummy3 : $maxOfSummary");
  }

  late double graphSize = physicalWidth - 2 * global.kMarginForGraph;

  late Map layout_yearPage = {
    'graphSize': {
      true: graphSize * global.kMagnificationOnGraph,
      false: graphSize
    },
    'left': {
      true: -graphSize *
          (global.kMagnificationOnGraph / 2) *
          (1 + (1 - global.kRatioOfScatterInYearPage)),
      false: global.kMarginForGraph
    },
    'top': {
      true: null,
      false: (physicalHeight -
                  global.kBottomNavigationBarHeight -
                  global.kHeightOfArbitraryWidgetOnBottom) *
              (global.kYPositionRatioOfGraph) -
          graphSize / 2
    }, //30 : bottom bar, 30: navigation bar, (1/3) positioned one third
    'graphCenter': {
      true: null,
      false: Offset(
          physicalWidth / 2,
          (physicalHeight -
                  global.kBottomNavigationBarHeight -
                  global.kHeightOfArbitraryWidgetOnBottom) *
              (global.kYPositionRatioOfGraph))
    }
  };

  @override
  Widget build(BuildContext context) {
    print("yearPage built");
    var isZoomIn =
        Provider.of<YearPageStateProvider>(context, listen: false).isZoomIn;
    return Scaffold(
      body: RawGestureDetector(
          behavior: HitTestBehavior.opaque,
          gestures: {
            AllowMultipleGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<
                        AllowMultipleGestureRecognizer>(
                    () => AllowMultipleGestureRecognizer(),
                    (AllowMultipleGestureRecognizer instance) {
              var provider =
                  Provider.of<YearPageStateProvider>(context, listen: true);
              instance.onTapUp = (details) {
                provider.setZoomInState(true);
                if (isZoomIn) return;
                Offset tapPosition =
                    calculateTapPositionRefCenter(details, 0, layout_yearPage);
                double angleZoomIn = calculateTapAngle(tapPosition, 0, 0);
                // if (tapPosition.dy < -200) return;
                //if editing text, doesn't zoom in.
                // setState(() {
                _angle = angleZoomIn;
                provider.setZoomInRotationAngle(_angle);
                // });
              };
            }),
            AllowMultipleGestureRecognizer2:
                GestureRecognizerFactoryWithHandlers<
                    AllowMultipleGestureRecognizer2>(
              () => AllowMultipleGestureRecognizer2(),
              (AllowMultipleGestureRecognizer2 instance) {
                var provider =
                    Provider.of<YearPageStateProvider>(context, listen: false);
                instance.onUpdate = (details) {
                  if (!isZoomIn) return;
                  _angle = isZoomIn ? _angle + details.delta.dy / 400 : 0;
                  provider.setZoomInRotationAngle(_angle);
                };
              },
            )
          },
          child: Stack(
              alignment: isZoomIn ? Alignment.center : Alignment.topCenter,
              children: [
                ZoomableWidgets(
                        widgets: [
                      Chart(
                        data: dataForPlot,
                        elements: [
                          PointElement(
                            size: SizeAttr(
                              variable: 'value',
                              values: !isZoomIn
                                  ? [
                                      global.kSizeOfScatter_ZoomOutMin,
                                      global.kSizeOfScatter_ZoomOutMax
                                    ]
                                  : [
                                      global.kSizeOfScatter_ZoomInMin,
                                      global.kSizeOfScatter_ZoomInMax
                                    ],
                            ),
                            color: ColorAttr(
                              variable: 'distance',
                              values: [
                                Colors.blue.withAlpha(200),
                                Colors.red.withAlpha(200),
                              ],
                            ),
                            selectionChannel: heatmapChannel,
                          ),
                        ],
                        variables: {
                          'week': Variable(
                            accessor: (List datum) => datum[0] as num,
                            scale: LinearScale(min: 0, max: 52, tickCount: 12),
                          ),
                          'day': Variable(
                            accessor: (List datum) => datum[1] as num,
                          ),
                          'value': Variable(
                            accessor: (List datum) => datum[2] as num,
                          ),
                          'distance': Variable(
                            accessor: (List datum) =>
                                // math.log(datum[3]) + 0.1 as num,
                                datum[3] as num,
                          ),
                        },
                        selections: {
                          'choose': PointSelection(
                            on: {GestureType.hover},
                            toggle: true,
                            nearest: false,
                            testRadius: isZoomIn ? 10 : 0,
                          )
                        },
                        coord: PolarCoord()
                          ..radiusRange = [
                            1 - global.kRatioOfScatterInYearPage,
                            1
                          ],
                        axes: [
                          Defaults.circularAxis
                            ..grid = null
                            ..label = null
                        ],
                      ),
                      Text(
                        "$year",
                        style: TextStyle(fontSize: 30),
                      ),
                      PolarMonthIndicators().build(context),
                    ],
                        isZoomIn: isZoomIn,
                        layout: layout_yearPage,
                        provider: Provider.of<YearPageStateProvider>(context,
                            listen: true))
                    .build(context)
              ])),
    );
  }
}
