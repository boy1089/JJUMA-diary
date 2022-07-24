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


//TODO : reduce the amount of data
//TODO : manage audio files.
//TODO : make timeslot descrete.
//TODO : get files from google.

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
  var sensorLogger;
  var dataReader;

  _MyHomePageState() {
    sensorLogger = SensorLogger();
    dataReader = DataReader('20220721');

  }

  void _incrementCounter() {
    setState(() {
      // dataReader.readData('20220721');
      print(dataReader.heatmapData2);
      // sensorLogger.writeCache();
      // sensorLogger.writeAudio();

      // print("findTimestamp : ${dataReader.findIndicesOf('21')}");

    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, fo
    // print("building widget : $heatmapData2");
    List<List<num>> heatmapData3 = [];
    print("building widget, ${dataReader.heatmapData2}");
    setState((){heatmapData3 = dataReader.heatmapData2;});
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Row(
          children: [
            SizedBox(width: 10),
            Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 50,
                  height: 1 * 700,
                  child: heatmapData3.isEmpty
                      ? Text("processing files, ${heatmapData3}")
                      : Chart(
                          padding: (_) => EdgeInsets.zero,
                          data: heatmapData3,
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
                                  const Color(0xffbae7af),
                                  const Color(0xff1890af),
                                  const Color(0xffc5553d)
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
