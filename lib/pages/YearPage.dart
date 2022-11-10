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

  _YearPageState() {}

  @override
  void initState() {
    print("year page create");
    updateData(Provider.of<YearPageStateProvider>(context, listen: false).year, false);
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
    if(setYear)
      Provider.of<YearPageStateProvider>(context, listen: false).setYear(year);
    this.year = year;
    availableDates = global.summaryOfPhotoData.keys.where((element) {
      return element.contains(year.toString());
    }).toList();
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
    var isZoomIn =
        Provider.of<YearPageStateProvider>(context, listen: false).isZoomIn;
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
                  var provider =
                      Provider.of<YearPageStateProvider>(context, listen: true);
                  instance.onTapUp = (details) {
                    provider.setZoomInState(true);
                    if (isZoomIn) return;
                    Offset tapPosition = calculateTapPositionRefCenter(
                        details, 0, layout_yearPage);
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
                    var provider = Provider.of<YearPageStateProvider>(context,
                        listen: false);
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
                    Positioned(
                      // duration: Duration(milliseconds: global.animationTime),
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
                        turns: isZoomIn
                            ? Provider.of<YearPageStateProvider>(context,
                                    listen: true)
                                .zoomInAngle
                            : 0,
                        duration:
                            Duration(milliseconds: global.animationTime - 100),
                        child: Stack(alignment: Alignment.center, children: [
                          PolarMonthIndicators().build(context),
                          Chart(
                            data: dataForPlot,
                            elements: [
                              PointElement(
                                size: SizeAttr(variable: 'value', values:
                                        !isZoomIn
                                        ?[1, maxOfSummary / 5]
                                    : [3.5, maxOfSummary / 10 * 3],
                                    ),
                                color: ColorAttr(
                                  variable: 'distance',
                                  values: [
                                    // Colors.black12,
                                    // Colors.green,
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
                            coord: PolarCoord()..radiusRange = [0.4, 1],
                            // tooltip: TooltipGuide(
                            //   anchor: (_) => Offset.zero,
                            // ),
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
                    updateData(year, true);
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
                      updateData(year, true);
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
        onPressed: (){
        },
      ),

    );
  }
}
