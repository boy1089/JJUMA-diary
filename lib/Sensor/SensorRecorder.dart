// import 'package:flutter/material.dart';
// import 'package:location/location.dart';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_sensors/flutter_sensors.dart';
// import 'package:lateDiary/Sensor/SensorData.dart';
// import 'package:intl/intl.dart';
// import 'package:lateDiary/Permissions/PermissionManager.dart';
//
// class SensorRecorder {
//   late PermissionManager permissionManager;
//   Location location = new Location();
//   bool enableAccel = false;
//
//   List<SensorData> _cacheData = [];
//   var _cacheCount = 0;
//
//   late Stream<SensorEvent> _streamAccel;
//   var _accelSubscription;
//   List<double> _accelData = [0, 0, 0];
//
//   SensorRecorder(permissionManager, {enableAccel = false}) {
//     this.permissionManager = permissionManager;
//     debugPrint("sensorRecorder instance created");
//
//     //writing once when it's created.. to make sure that there is file to read.
//     writeCache2();
//
//     // init();
//   }
//
//   Future<int> init() async {
//     print("SensorRecorder initializing...");
//     if (permissionManager.isLocationPermissionGranted) {
//       print("initializing SensorRecorder.. location permission not allowed");
//       return 0;
//     }
//     print('c');
//     location.enableBackgroundMode(enable: true);
//     print('d');
//     _enableLogging();
//     return 0;
//   }
//
//   void _enableLogging() async {
//     if (enableAccel) {
//       _streamAccel = await SensorManager().sensorUpdates(
//           sensorId: Sensors.ACCELEROMETER,
//           interval: Sensors.SENSOR_DELAY_NORMAL);
//
//       _accelSubscription = _streamAccel.listen((sensorEvent) {
//         _accelData = sensorEvent.data;
//       });
//     }
//     location.onLocationChanged.listen((LocationData currentLocation) {
//       _cacheCount = _cacheCount + 1;
//       // _accelData = _accelData;
//       print(_cacheCount);
//       _cacheData.add(SensorData(
//         DateTime.now(),
//         currentLocation.latitude,
//         currentLocation.longitude,
//         _accelData[0],
//         _accelData[1],
//         _accelData[2],
//       ));
//       if (_cacheCount > 10) {
//         writeCache2();
//         _cacheCount = 0;
//       }
//       debugPrint(
//           "SensorLogger _cacheCount $_cacheCount, ${currentLocation.latitude}, ${currentLocation.longitude}");
//     });
//     print('f');
//   }
//
//   void writeCache2() async {
//     final Directory? directory = await getApplicationDocumentsDirectory();
//     final String folder = '${directory?.path}/sensorData';
//     bool isFolderExists = await Directory(folder).exists();
//
//     final File file = File(
//         '${folder}/${DateFormat('yyyyMMdd').format(DateTime.now())}_sensor.csv');
//
//     if (!isFolderExists) {
//       Directory(folder).create(recursive: true);
//     }
//
//     bool isExists = await file.exists();
//     debugPrint("writing Cache to Local..");
//
//     if (!isExists)
//       await file.writeAsString(
//           'time, longitude, latitude, accelX, accelY, accelZ\n'
//           '${DateTime.now().toString()}, 0, 0, 0, 0, 0\n',
//           mode: FileMode.append);
//
//     for (int i = 0; i < _cacheData.length; i++) {
//       var line = _cacheData[i];
//       await file.writeAsString(
//           '${line.time.toString()}, ${line.longitude.toString()}, ${line.latitude.toString()}, ${line.accelX.toString()}'
//           ',${line.accelY.toString()}, ${line.accelZ.toString()}\n',
//           mode: FileMode.append);
//     }
//     _cacheData = [];
//     _cacheCount = 0;
//   }
// }
