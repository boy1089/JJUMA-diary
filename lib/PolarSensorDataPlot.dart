import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import 'package:flutter/foundation.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'global.dart';

class PolarSensorDataPlot {

  Color ColorForSensorDataOutline = Colors.black12;
  Color ColorForDummyData = Colors.white60;

  late dynamic data;
  PolarSensorDataPlot(this.data, {Key? key}); // {data = ['a'];}

  void addDummyDataForPlot() {
    debugPrint(data.toString());
    debugPrint(data.transpose.toString());
  }

  void printData(){
    print(data.toString());
  }

  @override
  Widget build(BuildContext context) {
    print("polarSensorDataPlot, $data");
    return Stack(
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
        data: data,
        variables: {
          '0': Variable(
            accessor: (List datum) => datum[0] as num,
            scale: LinearScale(min: 0, max: 24, tickCount: 5),
          ),
          'dummy': Variable(
            accessor: (List datum) => datum[6] as num,
          ),
          'latitude': Variable(
            accessor: (List datum) => datum[1] as num,
          ),
          'longitude': Variable(
            accessor: (List datum) => datum[2] as num,
          ),
          'accelX': Variable(
            accessor: (List datum) => datum[3] as num,
          ),
          'accelY': Variable(
            accessor: (List datum) => datum[4] as num,
          ),
          'accelZ': Variable(
            accessor: (List datum) => datum[5] as num,
          ),
        },
        elements: [
          PointElement(
            size: SizeAttr(variable: 'accelX',
                values: data ==dummyData?
                [0, 1]
                :[6, 7]),
            color: ColorAttr(
              variable: 'latitude',
              values: data==dummyData
                    ?[ColorForDummyData, ColorForDummyData ]
                :colorsHotCold

            ),
          ),
        ],
        axes: [
          Defaults.circularAxis
            ..labelMapper = (_, index, total) {
              if (index == total - 1) {
                return null;
              }
              return LabelStyle(
                  style: Defaults.textStyle);
            }
            ..label = null,
        ],
        coord: PolarCoord(),
      ),]
    );
  }
}
