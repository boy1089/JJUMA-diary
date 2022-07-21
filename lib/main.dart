import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:graphic/graphic.dart';
import 'dart:async';
import 'package:df/df.dart';

import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:test_location_2nd/SensorLogger.dart';
import 'package:test_location_2nd/DataReader.dart';

// TODO: read data, plot it
// --> class of data --> read data of specific date. make it organize.
// TODO: read dates, make it selectable.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final heatmapChannel = StreamController<Selected?>.broadcast();
  var sensorLogger = new SensorLogger();
  var dataReader = DataReader('a');

  _MyHomePageState() {}

  void _incrementCounter() {
    setState(() {
      dataReader.readData('20220722');
      print(dataReader.heatmapData2);
      sensorLogger.writeCache();
      sensorLogger.writeAudio();
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, fo
    // print("building widget : $heatmapData2");
    print("building widget, ${dataReader.heatmapData2}");
    setState((){});
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Row(
          children: [
            Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 100,
                  height: 1 * 500,
                  child: dataReader.heatmapData2 == []
                      ? Text("processing files")
                      : Chart(
                          padding: (_) => EdgeInsets.zero,
                          data: dataReader.heatmapData2,
                          // data: heatmapData,

                        variables: {
                            'name': Variable(
                              accessor: (List datum) => datum[0].toString(),
                            ),
                            'day': Variable(
                              accessor: (List datum) => datum[1].toString(),
                            ),
                            'sales': Variable(
                              accessor: (List datum) => datum[2] as num,
                            ),
                          },
                          elements: [
                            PolygonElement(
                              color: ColorAttr(
                                variable: 'sales',
                                values: [
                                  const Color(0xffbae7ff),
                                  const Color(0xff1890ff),
                                  const Color(0xff0050b3)
                                ],
                                updaters: {
                                  'tap': {false: (color) => color.withAlpha(70)}
                                },
                              ),
                              selectionChannel: heatmapChannel,
                            )
                          ],
                          selections: {'tap': PointSelection()},
                        ),
                ),
                Text("${_counter}")
              ],
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

const heatmapData = [
  [0, 0, 126.7207535],
  [1, 0, 37.3628223],
  [2, 0, 0.7446194887161255],
  [3, 0, 0.1532335877418518],
  [0, 1, 126.7207554],
  [1, 1, 37.3628241],
  [2, 1, 0.7757450342178345],
  [3, 1, 0.17478206753730774],
  [0, 2, 126.7207526],
  [1, 2, 37.3628222],
  [2, 2, 0.7446194887161255],
  [3, 2, 0.1484450399875641]
];
