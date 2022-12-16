import 'dart:async';
import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:lateDiary/Data/data_manager_interface.dart';
import 'package:lateDiary/Data/info_from_file.dart';
import 'package:lateDiary/StateProvider/day_page_state_provider.dart';
import 'package:lateDiary/app.dart';
import 'package:lateDiary/pages/DayPage/widgets/clickable_photo_card.dart';
import 'package:lateDiary/pages/DayPage/widgets/photo_card.dart';
import 'package:lateDiary/pages/setting_page.dart';
import 'package:matrix2d/matrix2d.dart';
import 'package:photo_view/photo_view.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';
// import 'package:vector_math/vector_math.dart' as vector;
// import 'package:vector_math/vector_math_64.dart';
import '../DayPage/model/event.dart';
import 'year_page_view.dart';
import 'package:provider/provider.dart';

import 'package:lateDiary/StateProvider/year_page_state_provider.dart';
import 'package:lateDiary/Util/global.dart' as global;
import 'package:go_router/go_router.dart';
import 'year_page_view_level1.dart';
import 'package:lateDiary/Util/Util.dart';

import 'package:photo_view/photo_view.dart';
import 'dart:math';


class YearPageScreen2 extends StatefulWidget {
  var context;
  YearPageScreen2({this.context});

  @override
  State<YearPageScreen2> createState() =>
      _YearPageScreen2State(context: context);
}

class _YearPageScreen2State extends State<YearPageScreen2> {
  int? selectedYear = null;
  BuildContext context;

  final heatmapChannel = StreamController<Selected?>.broadcast();

  bool isHeatMapChannelListening = false;
  _YearPageScreen2State({Key? key, required this.context}) {
    if (!isHeatMapChannelListening) addListenerToChart();
  }
  void addListenerToChart() {
    isHeatMapChannelListening = true;
    heatmapChannel.stream.listen(
      (value) async {
        print(value);
        var provider =
            Provider.of<YearPageStateProvider>(context, listen: false);
        // print(value!['tapDown']!.elementAt(0));
        // print(provider.dataForChart[value!['tapDown']!.elementAt(0)]);

        setState(() {
          selectedYear = provider.dataForChart[value!['tapDown']!.elementAt(0)]
              .elementAt(0);
          print("selected Year : $selectedYear");
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Consumer<YearPageStateProvider>(
      builder: (context, product, child) => Center(
        child: SizedBox(
          width: 500,
          height: 500,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Chart(
                data: product.dataForChart,
                variables: {
                  'week': Variable(
                    accessor: (List b) => b.elementAt(1) as num,
                    scale: LinearScale(min: 0, max: 52, tickCount: 12),
                  ),

                  'year': Variable(
                    accessor: (List b) => b.elementAt(0) as num,
                    scale: LinearScale(
                        min: DateTime.now().year - 10,
                        max: DateTime.now().year,
                        tickCount: 12),
                  ),
                  'weekday': Variable(
                    accessor: (List b) => b.elementAt(2) as num,
                    scale: LinearScale(min: -0.5, max: 6.5, tickCount: 7),
                  ),

                  'numberOfPhoto':
                      Variable(accessor: (List b) => b.elementAt(4) as num),
                  // 'latitude': Variable(accessor: (List b) => b.elementAt(3) as num),
                  // 'longitude': Variable(accessor: (List b) => b.elementAt(3) as num),
                },
                elements: [
                  PointElement(
                    size: SizeAttr(
                        encoder: (tuple) => log(tuple['numberOfPhoto']) * 10),
                    color: ColorAttr(
                      // value: Colors.blue.withAlpha(100),
                      encoder: (tuple) {
                        // print("updater : ${tuple['year']}, $selectedYear");
                        return tuple['year'] == selectedYear
                            ? Color.fromARGB(
                                100, tuple['numberOfPhoto'].ceil(), 200, 200)
                            : Color.fromARGB(
                                100, tuple['numberOfPhoto'].ceil(), 100, 100);
                      },
                      updaters: {
                        'tapDown': {
                          true: (color) {
                            setState(() {});
                            return color.withAlpha(200);
                          }
                        },
                        'tapCancel': {
                          true: (color) => color,
                        }
                      },
                    ),
                    selectionChannel: heatmapChannel,
                  )
                ],
                selections: {
                  'tapDown': PointSelection(
                      on: {GestureType.tapDown},
                      toggle: true,
                      nearest: true,
                      testRadius: 200),
                  'tapCancel': PointSelection(
                      on: {GestureType.tapCancel},
                      toggle: true,
                      nearest: true,
                      testRadius: 200)
                },
                coord: PolarCoord(
                    radiusRangeUpdater: Defaults.horizontalRangeSignal)
                  ..radiusRange = [1 - global.kRatioOfScatterInYearPage, 1]
                  ..endRadius = 1,
                axes: [
                  Defaults.circularAxis
                    ..grid = null
                    ..label = null,
                  // Defaults.radialAxis,
                ],
              ),
              // Container(width: 500, height: 500, child: Text("aabb"))
            ],
          ),
        ),
      ),
    ));
  }
}
