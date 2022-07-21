import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:df/df.dart';

import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:intl/intl.dart';

class DataReader{
  var _filesSensor;
  var _data;
  var longitudes;
  var latitudes;
  var accelXs;
  var accelYs;
  List<List<num>> heatmapData2 = [];
  var date;
  DataReader(date){
    readData(date);

  }

  void readData(date) async {

    debugPrint(DateFormat('yyyyMMdd_hhmmss').format(DateTime.now()));
    _data = await readCsv(date);
    // print(data.columnsNames);
    longitudes = _data.colRecords<double>(_data.columnsNames[1]);
    latitudes = _data.colRecords<double>(_data.columnsNames[2]);
    accelXs = _data.colRecords<double>(_data.columnsNames[3]);
    accelYs = _data.colRecords<double>(_data.columnsNames[4]);

    for(int i = 0; i<longitudes.length; i++){
      heatmapData2.add([0, i, longitudes[i]]);
      heatmapData2.add([1, i, latitudes[i]]);
      heatmapData2.add([2, i, accelXs[i]]);
      heatmapData2.add([3, i, accelYs[i]]);
    }
    print(heatmapData2);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    var path = directory.path;
    return path;
  }

  Future<DataFrame> readCsv(String date) async {

    var localPath = await _localPath;
    debugPrint("${localPath}/${date}_sensor.txt");
    final df = await DataFrame.fromCsv("${localPath}/${date}_sensor.txt");
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
}