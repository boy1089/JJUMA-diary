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

class sensorData {
  DateTime time = DateTime.now();
  double? latitude;
  double? longitude;
  double? accelX;
  double? accelY;
  double? accelZ;

  sensorData(time, latitude, longitude, accelX, accelY, accelZ) {
    this.time = time;
    this.latitude = latitude;
    this.longitude = longitude;
    this.accelX = accelX;
    this.accelY = accelY;
    this.accelZ = accelZ;
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  Location location = new Location();

  var _serviceEnabled;
  var _permissionGranted;
  var _locationData;

  List<sensorData> _cacheData = [];

  var _cacheCount = 0;
  var _cacheCount2 = 0;
  final _audioRecorder = Record();

  var _streamAccel;
  var _streamLight;
  var _accelSubscription;
  var _accelData;

  var _filesSensor;

  final heatmapChannel = StreamController<Selected?>.broadcast();

  var data;
  var longitudes;
  var latitudes;
  var accelXs;
  var accelYs;
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

  void setStream() async {

    _streamAccel = await SensorManager().sensorUpdates(
        sensorId: Sensors.ACCELEROMETER, interval: Sensors.SENSOR_DELAY_NORMAL);

    _accelSubscription = _streamAccel.listen((sensorEvent) {
      setState(() {
        _accelData = sensorEvent.data;
      });
    });
  }

  void checkStatus() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Check and request permission

    _locationData = await location.getLocation();
    debugPrint(_locationData.toString());

    location.onLocationChanged.listen((LocationData currentLocation) {
      _cacheCount = _cacheCount + 1;
      _cacheData.add(sensorData(
          DateTime.now(),
          currentLocation.latitude,
          currentLocation.longitude,
          _accelData[0],
          _accelData[1],
          _accelData[2]));
      if (_cacheCount > 1000) {
        _writeCache(_cacheData);
        _cacheData = [];
        _cacheCount = 0;
        record();
      }
    });
  }

  void _writeCache(List<sensorData> _cache) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File(
        '${directory.path}/${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}_sensor.txt');
    bool isExists = await file.exists();
    if(!isExists) await file.writeAsString('time, longitude, latitude, accelX, accelY, accelZ \n', mode : FileMode.append);

    for (int i = 0; i < _cache.length; i++) {
      var line = _cache[i];
      await file.writeAsString(
          '${line.time.toString()}, ${line.longitude.toString()}, ${line.latitude.toString()}, ${line.accelX.toString()}'
          ',${line.accelY.toString()}, ${line.accelZ.toString()}  \n',
          mode: FileMode.append);
    }
  }

  void record() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    if (await _audioRecorder.hasPermission() == false) return;
    bool isRecording = await _audioRecorder.isRecording();
    if (isRecording) await _audioRecorder.stop();
    await _audioRecorder.start(
      path:
          '${directory.path}/${_getCurrentTimestamp()}_audio.m4a',
      encoder: AudioEncoder.aacLc, // by default
      bitRate: 128000, // by default
      samplingRate: 44100, // by default
    );
  }
  String _getCurrentTimestamp(){
    return DateTime.now().toString().replaceAll('-', '').replaceAll(':', '').replaceAll(' ', '_').substring(0, 15);
  }

  void _incrementCounter() {
    setState(() {
      print(heatmapData2[0]);
      print(heatmapData2.runtimeType);
      print(heatmapData.runtimeType);

      _counter++;
      print(DateTime.now().toString().replaceAll('-', '').replaceAll(':', '').replaceAll(' ', '_').substring(0, 15));
      checkStatus();
      record();
      location.enableBackgroundMode(enable: true);
      setStream();

      _writeCache(_cacheData);
      _cacheData = [];
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
    print("local path : $_localPath");
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