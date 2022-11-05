import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'dart:math';
import 'package:test_location_2nd/Util/global.dart' as global;
import 'package:test_location_2nd/Util/StateProvider.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:test_location_2nd/Util/DateHandler.dart';

dynamic dummy2 = global.summaryOfPhotoData.values.toList();
List daysInYear = getDaysInBetween(
    DateTime(2022), DateTime(2023).subtract(Duration(days: 1)));

dynamic dummy = List.generate(365, (index) {
  DateTime date = daysInYear[index];
  return [
    (index / 7).floor(),
    index % 7,
    global.summaryOfPhotoData.containsKey(formatDate(date))
        ? global.summaryOfPhotoData[formatDate(date)]
        : 0
  ];
});

dynamic dummyDataForTest2 = List.generate(
    52 * 7,
    (index) => [
          (index / 7).floor(),
          index % 7,
          index > dummy2.length - 1 ? 0 : dummy2.elementAt(index)
        ]);

class YearPage extends StatefulWidget {
  const YearPage({Key? key}) : super(key: key);

  @override
  State<YearPage> createState() => _YearPageState();
}

class _YearPageState extends State<YearPage> {
  int year = DateTime.now().year;
  double _angle = 0;
  bool isZoomIn = false;

  double graphSize = 400;
  double topPadding = 100;

  var heatmapChannel = StreamController<Selected?>.broadcast();

  _YearPageState() {
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
        // provider.setZoomInState(false);
      },
    );
  }

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
    var provider = Provider.of<NavigationIndexProvider>(context, listen: true);
    var isZoomIn =
        Provider.of<NavigationIndexProvider>(context, listen: true).isZoomIn;

    return Scaffold(
      body: RawGestureDetector(
          behavior: HitTestBehavior.deferToChild,
          gestures: {
            AllowMultipleGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<
                        AllowMultipleGestureRecognizer>(
                    () => AllowMultipleGestureRecognizer(),
                    (AllowMultipleGestureRecognizer instance) {
              instance.onTapDown = (details) {
                print(global.indexForZoomInImage);
                if (isZoomIn) return;

                Offset tapPosition =
                    calculateTapPositionRefCenter(details, 0, layout_yearPage);
                double angleZoomIn = calculateTapAngle(tapPosition, 0, 0);

                if (tapPosition.dy < -200) return;
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
                  _angle = isZoomIn ? _angle + details.delta.dy / 1000 : 0;
                  provider.setZoomInRotationAngle(_angle);
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
                  width: layout_yearPage['graphSize']?[isZoomIn]?.toDouble(),
                  height: layout_yearPage['graphSize']?[isZoomIn]?.toDouble(),
                  left: layout_yearPage['left']?[isZoomIn]?.toDouble(),
                  top: layout_yearPage['top']?[isZoomIn]?.toDouble(),
                  curve: Curves.fastOutSlowIn,
                  child: AnimatedRotation(
                    turns: isZoomIn ? _angle : 0,
                    duration:
                        Duration(milliseconds: global.animationTime - 100),
                    child: Stack(alignment: Alignment.center, children: [
                      Text("$year"),
                      Chart(
                        data: dummy,
                        // selections : Selection(),
                        elements: [
                          PointElement(
                            size: SizeAttr(
                              variable: 'value',
                              values: !isZoomIn ? [1, 20] : [3.5, 60],
                            ),
                            color: ColorAttr(
                              variable: 'value',
                              values: [
                                global.kMainColor_warm,
                                global.kMainColor_warm
                              ],
                              updaters: {
                                'tap': {true: (a) => Colors.blue}
                              },
                            ),
                            // selected: Selected(),
                            selectionChannel: heatmapChannel,
                          ),
                        ],
                        variables: {
                          'week': Variable(
                            accessor: (List datum) => datum[0] as num,
                            scale: LinearScale(min: 0, max: 52, tickCount: 10),
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
                            testRadius: isZoomIn?5:0,
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
    );
  }
}
