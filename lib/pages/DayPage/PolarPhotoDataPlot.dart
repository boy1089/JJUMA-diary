import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import 'package:lateDiary/Util/Util.dart';
import '../../Util/global.dart' as global;

class PolarPhotoDataPlot {
  var googlePhotoDataForPlot;

  var dataForPlot;
  var isDataValid = false;
  PolarPhotoDataPlot(this.googlePhotoDataForPlot) {
    if (googlePhotoDataForPlot.length == 0) {
      dataForPlot = global.dummyData2;
      isDataValid = false;
    } else if ((googlePhotoDataForPlot[0].length == 0)) {
      dataForPlot = global.dummyData2;
      isDataValid = false;
    } else {
      dataForPlot = googlePhotoDataForPlot;
      isDataValid = true;
    }
  } // {data = ['a'];}

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Chart(
        data: global.dummyData2,
        variables: {
          '0': Variable(
            accessor: (List datum) => datum[0] as num,
            scale: LinearScale(min: 0, max: 24, tickCount: 5),
          ),
          'dummy': Variable(
            accessor: (List datum) => datum.last as num,
          ),
        },
        elements: [
          LineElement(
            color: ColorAttr(
              variable: 'dummy',
              values: [
                global.kColor_polarPlotOutline,
                global.kColor_polarPlotOutline
              ],
            ),
          ),
        ],
        coord: PolarCoord()..radiusRange = [0.0, 1.5],
      ),
      Chart(
        data: dataForPlot,
        elements: [
          PointElement(
            size: SizeAttr(
                variable: 'dummy',
                values: isDataValid
                    ? [
                        global.kSize_polarPlotPhotoScatter,
                        global.kSize_polarPlotPhotoScatter + 1
                      ]
                    : [0, 1]),
            // color: ColorAttr(variable: 'time', values: [
            //   global.kColor_polarPlotPhotoScatter,
            //   global.kColor_polarPlotPhotoScatter,
            // ])
            color: ColorAttr(
                // variable: 'time',
                encoder: (tuple) =>
                    global.kColorForYearPage[tuple['distance'].toInt()],
                // values: [
                //   global.kColor_polarPlotPhotoScatter,
                //   global.kColor_polarPlotPhotoScatter,
                // ]
            )
            ,
          ),
        ],
        variables: {
          'time': Variable(
            accessor: (List datum) => datum[0] as num,
            scale: LinearScale(min: 0, max: 24, tickCount: 5),
          ),
          'dummy': Variable(
            accessor: (List datum) => datum[3] as num,
          ),
          'distance': Variable(
            accessor: (List datum) => datum[2] as double,
          )
        },
        coord: PolarCoord()..radiusRange = [0.0, 1.5],
        axes: [
          Defaults.circularAxis
            ..grid = null
            ..label = null
        ],
      ),
    ]);
  }
}
