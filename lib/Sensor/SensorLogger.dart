import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:test_location_2nd/Sensor/SensorData.dart';
import 'package:intl/intl.dart';
import 'package:test_location_2nd/Usage/UsageLogger.dart';

class SensorLogger {
  Location location = new Location();
  UsageLogger usageLogger = new UsageLogger();

  var _serviceEnabled;
  var _permissionGranted;
  var _locationData;

  List<SensorData> _cacheData = [];

  var _cacheCount = 0;
  final _audioRecorder = Record();

  var _streamAccel;
  var _accelSubscription;
  var _accelData;

  var _lightData;

  var data;
  var longitudes;
  var latitudes;
  var accelXs;
  var accelYs;

  SensorLogger() {
    debugPrint("sensorLogger instance created");
    location.enableBackgroundMode(enable: true);
    _enableLogging();
    writeCache2();
  }

  void _enableLogging() async {
    _streamAccel = await SensorManager().sensorUpdates(
        sensorId: Sensors.ACCELEROMETER, interval: Sensors.SENSOR_DELAY_NORMAL);

    _accelSubscription = _streamAccel.listen((sensorEvent) {
      _accelData = sensorEvent.data;
    });

    location.onLocationChanged.listen((LocationData currentLocation) {
      _cacheCount = _cacheCount + 1;
      _lightData = _lightData ?? [0.0];
      _accelData = _accelData ??
          [
            0.0,
            0.0,
            0.0,
          ];
      _cacheData.add(SensorData(
        DateTime.now(),
        currentLocation.latitude,
        currentLocation.longitude,
        _accelData[0],
        _accelData[1],
        _accelData[2],
      ));

      if (_cacheCount > 500) {
        writeCache2();
        _cacheCount = 0;
        writeAudio2();
      }
      debugPrint(
          "SensorLogger _cacheCount $_cacheCount, ${_accelData.toString()} $_lightData");
    });
  }

  void writeCache2() async {
    final Directory? directory = await getExternalStorageDirectory();
    final String folder = '${directory?.path}/sensorData';
    bool isFolderExists = await Directory(folder).exists();

    final File file = File(
        '${folder}/${DateFormat('yyyyMMdd').format(DateTime.now())}_sensor.csv');

    if (!isFolderExists) {
      Directory(folder).create(recursive: true);
    }

    bool isExists = await file.exists();
    debugPrint("writing Cache to Local..");

    if (!isExists)
      await file.writeAsString(
          'time, longitude, latitude, accelX, accelY, accelZ\n'
          '${DateTime.now().toString()}, 0, 0, 0, 0, 0,\n',
          mode: FileMode.append);

    for (int i = 0; i < _cacheData.length; i++) {
      var line = _cacheData[i];
      await file.writeAsString(
          '${line.time.toString()}, ${line.longitude.toString()}, ${line.latitude.toString()}, ${line.accelX.toString()}'
          ',${line.accelY.toString()}, ${line.accelZ.toString()}}  \n',
          mode: FileMode.append);
    }
    _cacheData = [];
    _cacheCount = 0;
  }

  void writeAudio2() async {
    final Directory? directory = await getExternalStorageDirectory();
    final String folder = '${directory?.path}/audioData';
    bool isFolderExists = await Directory(folder).exists();

    if (!isFolderExists) {
      Directory(folder).create(recursive: true);
    }

    if (await _audioRecorder.hasPermission() == false) return;
    bool isRecording = await _audioRecorder.isRecording();
    if (isRecording) await _audioRecorder.stop();

    await _audioRecorder.start(
      path:
          '${folder}/${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}_audio.m4a',
      encoder: AudioEncoder.aacLc, // by default
      bitRate: 128000, // by default
      samplingRate: 44100, // by default
    );
  }

  void forceWrite() {
    _cacheCount = 1000;
  }
}
