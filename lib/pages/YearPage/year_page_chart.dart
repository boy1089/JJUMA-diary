import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:lateDiary/Util/layouts.dart';
import 'package:provider/provider.dart';
import 'package:lateDiary/StateProvider/navigation_index_state_provider.dart';
import 'package:lateDiary/Util/DateHandler.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:lateDiary/StateProvider/day_page_state_provider.dart';
import 'package:lateDiary/StateProvider/year_page_state_provider.dart';

import 'package:graphic/graphic.dart';

class YearPageChart extends StatelessWidget {
  dynamic dataForChart;
  bool isZoomIn;
  StreamController<Selected?> heatmapChannel =
      StreamController<Selected?>.broadcast();

  bool isHeatMapChannelListening = false;
  BuildContext context;

  YearPageChart(
      {required this.dataForChart,
      required this.isZoomIn,
      required this.context}) {
    if (!isHeatMapChannelListening) addListenerToChart();
  }

  void addListenerToChart() {
    isHeatMapChannelListening = true;
    heatmapChannel.stream.listen(
      (value) async {
        YearPageStateProvider product =
            Provider.of<YearPageStateProvider>(context, listen: false);
        var provider =
            Provider.of<NavigationIndexProvider>(context, listen: false);

        if (value == null) return;
        if (!product.isZoomIn) return;

        switch (value.keys.elementAt(0)) {
          case "tapDown":
            break;
          case 'tapUp':
            print("value : $value");

            // DateTime date = DateTime.parse(product.availableDates
            //     .elementAt(int.parse(value.values.first.first.toString())));
            DateTime date = formatDateString(dataForChart.elementAt(value.values.first.first)[4].toString());
            if (!product.isZoomIn) return;
            provider.setNavigationIndex(navigationIndex.day);
            provider.setDate(date);
            Provider.of<DayPageStateProvider>(context, listen: false)
                .setAvailableDates(product.availableDates);
            // Navigator.pushNamed(DayPageView.id)

            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Chart(
      data: dataForChart,
      elements: [
        PointElement(
          position: Varset('week') * (Varset('day')),
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
            encoder: (tuple) => global
                .kColorForYearPage[tuple['distance'].toInt()]
                .withAlpha((50 + tuple['value']).toInt()),
            updaters: {
              'tapDown': {true: (color) => color.withAlpha(150)},
              'tapUp': {true: (color) => color.withAlpha(150)}
            },
          ),
          selectionChannel: heatmapChannel,
        ),
      ],
      variables: {
        'week': Variable(
          accessor: (List datum) => datum[0] + 0.5
              as num, // 0.5 is added to match the tap area and dot
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
        'tapDown': PointSelection(
          on: {GestureType.tapDown},
          toggle: true,
          nearest: false,
          testRadius: isZoomIn ? 10 : 0,
        ),
        'tapUp': PointSelection(
          on: {GestureType.tapUp},
          toggle: true,
          nearest: false,
          testRadius: isZoomIn ? 10 : 0,
        )
      },
      coord: PolarCoord()
        ..radiusRange = [1 - global.kRatioOfScatterInYearPage, 1],
      axes: [
        Defaults.circularAxis
          ..grid = null
          ..label = null
      ],
    );
  }
}
