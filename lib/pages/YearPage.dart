import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'dart:math';
import 'package:test_location_2nd/Util/global.dart' as global;

dynamic dummy2 = global.summaryOfPhotoData.values.toList();

dynamic dummyDataForTest2 = List.generate(
    52 * 7,
    (index) => [
          (index / 7).floor(),
          index % 7,
          index > dummy2.length - 1 ? 0 : dummy2.elementAt(index)
        ]);

class YearPage extends StatefulWidget {
  const YearPage({Key? key}) : super(key: key);

  @override
  State<YearPage> createState() => _YearPageState();
}

class _YearPageState extends State<YearPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Text("aaa"),
        Container(
          width: 500,
          height: 500,
          child: Chart(
            data: dummyDataForTest2,
            elements: [
              PointElement(
                  size: SizeAttr(variable: 'value', values: [1, 20]),
                  color: ColorAttr(variable: 'value', values: [
                    global.kMainColor_warm,
                    global.kMainColor_warm
                  ])),
            ],
            variables: {
              'week': Variable(
                accessor: (List datum) => datum[0] as num,
                scale: LinearScale(min: 0, max: 52, tickCount: 10),
              ),
              'day': Variable(
                accessor: (List datum) => datum[1] as num,
              ),
              'value': Variable(
                accessor: (List datum) => datum[2] as num,
              ),
            },
            coord: PolarCoord()..radiusRange = [0.6, 1],
          ),
        ),
      ]),
    );
  }
}
