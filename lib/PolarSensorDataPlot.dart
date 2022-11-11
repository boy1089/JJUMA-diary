import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import 'package:flutter/foundation.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'Util/global.dart' as global;

class PolarSensorDataPlot {
  Color ColorForSensorDataOutline = Colors.black12;
  Color ColorForDummyData = Colors.black12.withAlpha(0);

  late dynamic data;
  PolarSensorDataPlot(this.data, {Key? key}); // {data = ['a'];}

  @override
  Widget build(BuildContext context) {
    print("polarSensorDataPlot, ${data[0]}, ${data[0].length}");
    return Stack(children: [
      Chart(
        data: global.dummyData1,
        variables: {
          '0': Variable(
            accessor: (List datum) => datum[0] as num,
            scale: LinearScale(min: 0, max: 24, tickCount: 5),
          ),
          'dummy': Variable(
            accessor: (List datum) => datum[6] as num,
          ),
        },
        elements: [
          LineElement(
            color: ColorAttr(
              variable: 'dummy',
              values: [global.kColor_polarPlotOutline, global.kColor_polarPlotOutline],
            ),
          ),
        ],
        coord: PolarCoord()..radiusRange = [0.0, 1.3],
      ),
      Chart(
        data: data,
        variables: {
          '0': Variable(
            accessor: (List datum) => datum[0] as num,
            scale: LinearScale(min: 0, max: 24, tickCount: 5),
          ),
          'dummy': Variable(
            accessor: (List datum) => datum[data[0].length - 1] as num,
          ),
          'latitude': Variable(
            accessor: (List datum) => (datum[1] - 37.362791) * 5.abs() as num,
          ),
          'longitude': Variable(
            accessor: (List datum) => datum[2] as num,
          ),
        },
        elements: [
          PointElement(
            color: ColorAttr(
                variable: 'latitude',
                values: data == global.dummyData1
                    ? [ColorForDummyData, ColorForDummyData]
                    : global.colorsHotCold),
          ),
        ],
        axes: [
          Defaults.circularAxis
            ..labelMapper = (_, index, total) {
              if (index == total - 1) {
                return null;
              }
              return LabelStyle(style: Defaults.textStyle);
            }
          ..label = null
          ..grid = null
          // ..grid = null
          // ..line = null
        ],
        coord: PolarCoord()..radiusRange = [0.0, 1.3],
      ),
    ]);
  }
}
