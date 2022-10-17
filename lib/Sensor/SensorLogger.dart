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

  var _streamLight;
  var _lightData;
  var _lightSubscription;

  var _streamProximity;
  var _proximityData = [0.0];
  var _proximitySubscription;

  var _streamHumidity;
  var _humidityData = 0.0;
  var _humiditySubscription;

  var _streamTemperature;
  var _temperatureData = 0.0;
  var _temperatureSubscription;

  var data;
  var longitudes;
  var latitudes;
  var accelXs;
  var accelYs;
  var temperatures;
  var lights;
  var humidities;
  var proximities;

  SensorLogger() {
    debugPrint("sensorLogger instance created");
    location.enableBackgroundMode(enable: true);
    _enableLogging();
    writeCache2();
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
    print('permission?');
    if (await _permissionGranted == PermissionStatus.denied) return;
    print('ok!');
    _locationData = await location.getLocation();

    _streamAccel = await SensorManager().sensorUpdates(
        sensorId: Sensors.ACCELEROMETER, interval: Sensors.SENSOR_DELAY_NORMAL);
    _accelSubscription = _streamAccel.listen((sensorEvent) {
      _accelData = sensorEvent.data;
    });

    // _streamLight = await SensorManager().sensorUpdates(sensorId: Sensors.LIGHT, interval: Sensors.SENSOR_DELAY_NORMAL);
    //sensor Light int is 5; https://developer.android.com/reference/android/hardware/Sensor#TYPE_LIGHT
    _streamLight = await SensorManager()
        .sensorUpdates(sensorId: 5, interval: Sensors.SENSOR_DELAY_NORMAL);
    _lightSubscription = _streamLight.listen((sensorEvent) {
      _lightData = sensorEvent.data;
    });
    // _streamTemperature = await SensorManager().sensorUpdates(sensorId: 13, interval: Sensors.SENSOR_DELAY_NORMAL);
    // _temperatureSubscription = _streamTemperature.listen((sensorEvent){
    //   _temperatureData = sensorEvent.data;
    // });
    // _streamProximity= await SensorManager().sensorUpdates(sensorId: 8, interval: Sensors.SENSOR_DELAY_NORMAL);
    // _proximitySubscription = _streamProximity.listen((sensorEvent){
    //   _proximityData = sensorEvent.data;
    // });
    // _streamHumidity = await SensorManager().sensorUpdates(sensorId: 12, interval: Sensors.SENSOR_DELAY_NORMAL);
    // _humiditySubscription = _streamHumidity.listen((sensorEvent){
    //   _humidityData = sensorEvent.data;
    // });

    location.onLocationChanged.listen((LocationData currentLocation) {
      _cacheCount = _cacheCount + 1;
      _lightData = _lightData ?? [0.0];
      _accelData = _accelData ??
          [
            0.0,
            0.0,
            0.0,
          ];

      // print(_accelData);
      // print(_temperatureData);
      // print(_proximityData);
      // print(_humidityData);
      // print(currentLocation.latitude);

      _cacheData.add(SensorData(
          DateTime.now(),
          currentLocation.latitude,
          currentLocation.longitude,
          _accelData[0],
          _accelData[1],
          _accelData[2],
          _lightData[0],
          _temperatureData,
          _proximityData[0],
          _humidityData));

      if (_cacheCount > 500) {
        writeCache2();
        _cacheCount = 0;
        writeAudio2();
        usageLogger.getEvents(
            DateTime.parse(DateFormat('yyyyMMdd').format(DateTime.now())),
            DateTime.now());
        usageLogger.getEventInfo(
            DateTime.parse(DateFormat('yyyyMMdd').format(DateTime.now())),
            DateTime.now());
        usageLogger.getUsageStat(
            DateTime.parse(DateFormat('yyyyMMdd').format(DateTime.now())),
            DateTime.now());

        usageLogger.writeCache3();
        // usageLogger.writeCache3();
        // usageLogger.writeCache4();

        // usageLogger.writeCache();
      }
      debugPrint(
          "SensorLogger _cacheCount $_cacheCount, ${_accelData.toString()} $_lightData, $_temperatureData, $_proximityData, $_humidityData");
    });
  }

  void writeCache() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File(
        '${directory.path}/sensorData/${DateFormat('yyyyMMdd').format(DateTime.now())}_sensor.csv');
    bool isExists = await file.exists();
    debugPrint("writing Cache to Local..");

    if (!isExists)
      await file.writeAsString(
          'time, longitude, latitude, accelX, accelY, accelZ, light, temperature, proximity, humidity \n',
          mode: FileMode.append);

    for (int i = 0; i < _cacheData.length; i++) {
      var line = _cacheData[i];
      await file.writeAsString(
          '${line.time.toString()}, ${line.longitude.toString()}, ${line.latitude.toString()}, ${line.accelX.toString()}'
          ',${line.accelY.toString()}, ${line.accelZ.toString()}, ${line.light.toString()}, ${line.temperature.toString()}'
          ', ${line.proximity.toString()}, ${line.humidity.toString()}  \n',
          mode: FileMode.append);
    }
    _cacheData = [];
    _cacheCount = 0;
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
          // 'time, longitude, latitude, accelX, accelY, accelZ \n',
          'time, longitude, latitude, accelX, accelY, accelZ, light, temperature, proximity, humidity \n'
          '${DateTime.now().toString()}, 0, 0, 0, 0, 0, 0, 0, 0, 0 \n',
          mode: FileMode.append);

    for (int i = 0; i < _cacheData.length; i++) {
      var line = _cacheData[i];
      await file.writeAsString(
          '${line.time.toString()}, ${line.longitude.toString()}, ${line.latitude.toString()}, ${line.accelX.toString()}'
          ',${line.accelY.toString()}, ${line.accelZ.toString()}, ${line.light.toString()}, ${line.temperature.toString()}'
          ', ${line.proximity.toString()}, ${line.humidity.toString()}  \n',
          mode: FileMode.append);
    }
    _cacheData = [];
    _cacheCount = 0;
  }

  void writeAudio() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    if (await _audioRecorder.hasPermission() == false) return;
    bool isRecording = await _audioRecorder.isRecording();
    if (isRecording) await _audioRecorder.stop();

    await _audioRecorder.start(
      path:
          '${directory.path}/${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}_audio.m4a',
      encoder: AudioEncoder.aacLc, // by default
      bitRate: 128000, // by default
      samplingRate: 44100, // by default
    );
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
