import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:test_location_2nd/Util/global.dart' as global;
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:test_location_2nd/PolarMonthIndicator.dart';
import 'package:test_location_2nd/CustomWidget/ZoomableWidgets.dart';

import 'package:test_location_2nd/StateProvider/YearPageStateProvider.dart';
import 'package:test_location_2nd/StateProvider/DayPageStateProvider.dart';
import 'package:test_location_2nd/StateProvider/NavigationIndexStateProvider.dart';


class YearPage extends StatefulWidget {
  YearPage({Key? key}) : super(key: key) {}

  @override
  State<YearPage> createState() => _YearPageState();
}

class _YearPageState extends State<YearPage> {
  var heatmapChannel = StreamController<Selected?>.broadcast();

  late Map layout_yearPage = {
    'graphSize': {
      true: graphSize * global.kMagnificationOnYearPage,
      false: graphSize
    },
    'left': {
      true: -graphSize *
          (global.kMagnificationOnYearPage / 2) *
          (1 + (1 - global.kRatioOfScatterInYearPage)),
      false: global.kMarginForYearPage
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
  late double graphSize = physicalWidth - 2 * global.kMarginForYearPage;

  @override
  void initState() {
    print("year page create");
    // Provider.of<YearPageStateProvider>(context, listen: false).updateData();
    heatmapChannel.stream.listen(
      (value) {
        var provider =
            Provider.of<NavigationIndexProvider>(context, listen: false);
        var yearPageStateProvider =
            Provider.of<YearPageStateProvider>(context, listen: false);

        if (value == null) return;
        if (!yearPageStateProvider.isZoomIn) return;

        DateTime date = DateTime.parse(yearPageStateProvider.availableDates
            .elementAt(int.parse(value.values.first.first.toString())));
        if (!yearPageStateProvider.isZoomIn) return;
        provider.setNavigationIndex(2);
        provider.setDate(date);
        Provider.of<DayPageStateProvider>(context, listen: false)
            .setAvailableDates(yearPageStateProvider.availableDates);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<YearPageStateProvider>(
      builder: (context, product, child) => Scaffold(
        body: RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            gestures: {
              AllowMultipleGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<
                          AllowMultipleGestureRecognizer>(
                      () => AllowMultipleGestureRecognizer(),
                      (AllowMultipleGestureRecognizer instance) {
                instance.onTapUp = (details) {
                  product.setZoomInState(true);
                  if (product.isZoomIn) return;
                  Offset tapPosition = calculateTapPositionRefCenter(
                      details, 0, layout_yearPage);
                  double angleZoomIn = calculateTapAngle(tapPosition, 0, 0);
                  product.setZoomInRotationAngle(angleZoomIn);
                };
              }),
              AllowMultipleGestureRecognizer2:
                  GestureRecognizerFactoryWithHandlers<
                      AllowMultipleGestureRecognizer2>(
                () => AllowMultipleGestureRecognizer2(),
                (AllowMultipleGestureRecognizer2 instance) {
                  instance.onUpdate = (details) {
                    if (!product.isZoomIn) return;
                    product.setZoomInRotationAngle(product.isZoomIn
                        ? product.zoomInAngle + details.delta.dy / 400
                        : 0);
                  };
                },
              )
            },
            child: Stack(
                alignment:
                    product.isZoomIn ? Alignment.center : Alignment.topCenter,
                children: [
                  ZoomableWidgets(
                          widgets: [
                        Chart(
                          data: product.data,
                          elements: [
                            PointElement(
                              size: SizeAttr(
                                variable: 'value',
                                values: !product.isZoomIn
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
                              scale:
                                  LinearScale(min: 0, max: 52, tickCount: 12),
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
                              testRadius: product.isZoomIn ? 10 : 0,
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
                          "${product.year}",
                          style: TextStyle(fontSize: 30),
                        ),
                        PolarMonthIndicators().build(context),
                      ],
                          isZoomIn: product.isZoomIn,
                          layout: layout_yearPage,
                          provider: product)
                      .build(context)
                ])),
      ),
    );
  }
}
