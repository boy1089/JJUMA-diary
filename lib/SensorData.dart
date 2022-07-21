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


class SensorData {
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