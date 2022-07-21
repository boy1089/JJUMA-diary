import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:test_location_2nd/SensorData.dart';

class SensorLogger {
  Location location = new Location();

  var _serviceEnabled;
  var _permissionGranted;
  var _locationData;

  List<SensorData> _cacheData = [];

  var _cacheCount = 0;
  final _audioRecorder = Record();

  var _streamAccel;
  var _accelSubscription;
  var _accelData;


  var data;
  var longitudes;
  var latitudes;
  var accelXs;
  var accelYs;

  SensorLogger() {
    debugPrint("sensorLogger instance created");
    location.enableBackgroundMode(enable: true);
    _enableLogging();
  }




  void _enableLogging() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    if (!(await _serviceEnabled)) return;

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    if (await _permissionGranted == PermissionStatus.denied) return;

    _locationData = await location.getLocation();

    _streamAccel = await SensorManager().sensorUpdates(
        sensorId: Sensors.ACCELEROMETER, interval: Sensors.SENSOR_DELAY_NORMAL);
    _accelSubscription = _streamAccel.listen((sensorEvent) {
      _accelData = sensorEvent.data;
    });

    location.onLocationChanged.listen((LocationData currentLocation) {
      _cacheCount = _cacheCount + 1;
      _cacheData.add(SensorData(
          DateTime.now(),
          currentLocation.latitude,
          currentLocation.longitude,
          _accelData[0],
          _accelData[1],
          _accelData[2]));

      if (_cacheCount > 1000) {
        writeCache();
        _cacheCount = 0;
        writeAudio();
      }
      debugPrint("SensorLogger _cacheCount $_cacheCount");
    });
  }

  void writeCache() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File(
        '${directory.path}/${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}_sensor.txt');
    bool isExists = await file.exists();
    debugPrint("writing Cache to Local..");

    if (!isExists)
      await file.writeAsString(
          'time, longitude, latitude, accelX, accelY, accelZ \n',
          mode: FileMode.append);

    for (int i = 0; i < _cacheData.length; i++) {
      var line = _cacheData[i];
      await file.writeAsString(
          '${line.time.toString()}, ${line.longitude.toString()}, ${line.latitude.toString()}, ${line.accelX.toString()}'
          ',${line.accelY.toString()}, ${line.accelZ.toString()}  \n',
          mode: FileMode.append);
    }
    _cacheData = [];
  }

  void writeAudio() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    if (await _audioRecorder.hasPermission() == false) return;
    bool isRecording = await _audioRecorder.isRecording();
    if (isRecording) await _audioRecorder.stop();
    await _audioRecorder.start(
      path: '${directory.path}/${_getCurrentTimestamp()}_audio.m4a',
      encoder: AudioEncoder.aacLc, // by default
      bitRate: 128000, // by default
      samplingRate: 44100, // by default
    );
  }

  String _getCurrentTimestamp() {
    return DateTime.now()
        .toString()
        .replaceAll('-', '')
        .replaceAll(':', '')
        .replaceAll(' ', '_')
        .substring(0, 15);
  }
}
