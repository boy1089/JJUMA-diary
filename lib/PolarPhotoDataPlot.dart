import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import 'package:test_location_2nd/Util/Util.dart';
import 'global.dart';

class PolarPhotoDataPlot {
  var googlePhotoDataForPlot;
  PolarPhotoDataPlot(this.googlePhotoDataForPlot); // {data = ['a'];}

  Color ColorForSensorDataOutline = Colors.lightBlueAccent;
  Color ColorForDummyData = Colors.lightBlueAccent;
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 10),
        width: kThirdPolarPlotSize,
        height: kThirdPolarPlotSize,
        child: Stack(
          children: [
            Chart(
              data : dummyData,
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
                    values:[ColorForSensorDataOutline,ColorForSensorDataOutline ],
                  ),
                ),
              ],
              coord: PolarCoord(),
            ),
            Chart(
            data: ((googlePhotoDataForPlot[0].length == 0))
                ? dummyData
                : googlePhotoDataForPlot.sublist(0),
            elements: [
              PointElement(
                size: SizeAttr(variable: 'dummy', values: [7, 8]),
              ),
            ],
            variables: {
              'time': Variable(
                accessor: (List datum) => datum[0] as num,
                scale: LinearScale(min: 0, max: 24, tickCount: 5),
              ),
              'dummy': Variable(
                accessor: (List datum) => datum[2] as num,
              ),
            },
            coord: PolarCoord(),
          ),]
        ));
  }
}
