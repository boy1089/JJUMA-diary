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

class YearPageScreen2 extends StatelessWidget {
  YearPageScreen2({Key? key}) : super(key: key);
  final heatmapChannel = StreamController<Selected?>.broadcast();
  @override
  Widget build(BuildContext context) {
    int i = 0;

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
                      encoder : (tuple)=> Color.fromARGB(100, tuple['numberOfPhoto'].ceil(), 100, 100),
                      updaters: {
                        'tapDown': {
                          true: (color) {
                            return color.withAlpha(200);
                          }
                        },
                        'tapCancel': {
                          true: (color) => color,
                        }
                      },
                    ),

                    // selectionChannel: heatmapChannel,
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
