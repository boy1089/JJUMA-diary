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
import 'package:test_location_2nd/SensorData.dart';
import 'package:test_location_2nd/SensorLogger.dart';

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
  var _filesSensor;
  var data;
  var longitudes;
  var latitudes;
  var accelXs;
  var accelYs;
  final heatmapChannel = StreamController<Selected?>.broadcast();

  var sensorLogger = new SensorLogger();

  List<List<num>> heatmapData2 = [];

  _MyHomePageState(){
    updateState();
  }

  void updateState() async {
    _filesSensor = await getFiles();
    print(_filesSensor);
    print(_filesSensor.last);
    data = await readCsv(_filesSensor[4].path);
    print(_filesSensor.last);
    // print(data.columnsNames);
    longitudes = data.colRecords<double>(data.columnsNames[1]);
    latitudes = data.colRecords<double>(data.columnsNames[2]);
    accelXs = data.colRecords<double>(data.columnsNames[3]);
    accelYs = data.colRecords<double>(data.columnsNames[4]);

    for(int i = 0; i<longitudes.length; i++){
      heatmapData2.add([0, i, longitudes[i]]);
      heatmapData2.add([1, i, latitudes[i]]);
      heatmapData2.add([2, i, accelXs[i]]);
      heatmapData2.add([3, i, accelYs[i]]);

    }
  print(heatmapData2);
  }


  void _incrementCounter() {
    setState(() {
      sensorLogger.writeAudio();
      sensorLogger.writeCache();
    });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    var path = directory.path;
    return path;
  }

  Future<DataFrame> readCsv(String path) async {
    final df = await DataFrame.fromCsv(path);
    return df;
  }

  Future<List<File>> getFiles() async {
    var a = await _localPath;
    var kRoot = a;
    var fm = FileManager(root: Directory(kRoot)); //
    var b;
    b = fm.filesTree(extensions: ["txt"]);
    return b;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, fo
    // print("building widget : $heatmapData2");
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(

          child: Column(
            children: <Widget>[

              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 100,
                height: 1 * 1000,
                child:  heatmapData2 == []
            ? Text("processing files")
                : Chart(
                  padding: (_) => EdgeInsets.zero,
                  data: heatmapData,

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
      ),


      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

const heatmapData = [[0, 0, 126.7207535], [1, 0, 37.3628223], [2, 0, 0.7446194887161255], [3, 0, 0.1532335877418518], [0, 1, 126.7207554], [1, 1, 37.3628241], [2, 1, 0.7757450342178345], [3, 1, 0.17478206753730774], [0, 2, 126.7207526], [1, 2, 37.3628222], [2, 2, 0.7446194887161255], [3, 2, 0.1484450399875641]];