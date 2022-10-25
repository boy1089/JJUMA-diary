import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import 'package:test_location_2nd/Util/Util.dart';
import 'global.dart';

class PolarPhotoDataPlot {
  var googlePhotoDataForPlot;

  var dataForPlot;
  var isDataValid = false;
  PolarPhotoDataPlot(this.googlePhotoDataForPlot){
    if (googlePhotoDataForPlot.length == 0){
      dataForPlot = dummyData;
      isDataValid = false;
    } else if((googlePhotoDataForPlot[0].length == 0)){
      dataForPlot = dummyData;
      isDataValid = false;
    }else{
      dataForPlot = googlePhotoDataForPlot;
      isDataValid = true;
    }
  } // {data = ['a'];}

  Color ColorForSensorDataOutline = Colors.lightBlueAccent;
  Color ColorForDummyData = Colors.lightBlueAccent;
  @override
  Widget build(BuildContext context) {
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
              accessor: (List datum) => datum.last as num,
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
          coord: PolarCoord()..radiusRange = [0.0, 1.5],
        ),
        Chart(
        data: dataForPlot,
        elements: [
          PointElement(

            size: SizeAttr(variable: 'dummy',
                values: isDataValid?
                [7, 8]:[0, 1]),
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
        coord: PolarCoord()..radiusRange = [0.0, 1.5],
      ),]
    );
  }
}
