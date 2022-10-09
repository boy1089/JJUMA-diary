import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import 'package:flutter/foundation.dart';
import 'package:matrix2d/matrix2d.dart';
import 'package:test_location_2nd/Util/Util.dart';

class PolarPhotoDataPlot {
  late List<List<dynamic>> data;
  PolarPhotoDataPlot(this.data, {Key? key}); // {data = ['a'];}



  @override
  Widget build(BuildContext context) {
    return Chart(
      data: data,
      variables: {
        '0': Variable(
          accessor: (List datum) => datum[0] as num,
          scale: LinearScale(min: 0, max: 24, tickCount: 5),
        ),
        'dummy': Variable(
          accessor: (List datum) => datum[1] as num,
        ),
        // 'test': Variable(
        //   accessor: (List datum) => datum[1] as num,
        // ),

      },
      elements: [
        PointElement(
          size: SizeAttr(variable: 'dummy', values: [6, 7]),
          // shape : ShapeAttr(variable : 'dummy', value : CircleShape()),
          color: ColorAttr(
            variable : 'dummy',
          values : [Colors.blueAccent,Colors.blueAccent ],
          //   variable: 'latitude',
          //   values: colorsHotCold,
          //   updaters: {
          //     'choose': {true: (_) => Colors.red}
          //   },
          // ),
        )),
      ],
      axes: [
        // Defaults.circularAxis
        //   ..labelMapper = (_, index, total) {
        //     if (index == total - 1) {
        //       return null;
        //     }
        //     return LabelStyle(
        //         style: Defaults.textStyle);
        //   }
        //   ..label = null,
        Defaults.radialAxis
          // ..labelMapper = (_, index, total) {
          //   if (index == total - 1) {
          //     return null;
          //   }
          //   return LabelStyle(
          //       style: Defaults.textStyle);
          // }
          ..label = null,
      ],
      coord: PolarCoord(),
      selections: {
        'choose': PointSelection(toggle: false)
      },
      tooltip: TooltipGuide(
        anchor: (_) => Offset.zero,
        align: Alignment.bottomRight,
        multiTuples: true,
      ),
    );
  }
}
