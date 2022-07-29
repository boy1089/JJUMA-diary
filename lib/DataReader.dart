import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:df/df.dart';

import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:intl/intl.dart';
import 'package:test_location_2nd/Util.dart';

class DataReader{
  var _filesSensor;
  var _data;
  var longitudes;
  var latitudes;
  var accelXs;
  var accelYs;
  var times;
  List<List<num>> heatmapData2 = [];
  var date;
  DataReader(date){
    readData(date);

  }

  void readData(date) async {

    _data = await readCsv(date);
    // print(data.columnsNames);
    longitudes = _data.colRecords<double>(_data.columnsNames[1]);
    latitudes = _data.colRecords<double>(_data.columnsNames[2]);
    accelXs = _data.colRecords<double>(_data.columnsNames[3]);
    accelYs = _data.colRecords<double>(_data.columnsNames[4]);
    times = _data.colRecords<DateTime>(_data.columnsNames[0]);
    debugPrint(date.substring(6, 8));
    List<int> indices = findIndicesOf(date.substring(6, 8));
    debugPrint("datareader : readData: indices: $indices");
    for(int i = 0; i<indices.length; i++){
        print(indices[i]);
        heatmapData2.add([0, i, longitudes[indices[i]]]);
        heatmapData2.add([1, i, latitudes[indices[i]]]);
        heatmapData2.add([2, i, accelXs[indices[i]]]);
        heatmapData2.add([3, i, accelYs[indices[i]]]);
      }
    print(heatmapData2);
  }

  int findIndexOf(day, hour) {
    // print(times[0].day.toString());

    for( int i = 0; i< times.length; i++){
      if((times[i].day.toString() != day)) continue;
      if(times[i].hour.toString() == hour) return i;
    }
    return 0;

  }
  List<int> findIndicesOf(day){
    List<int> indexOfTime = [];

    for(int i= 0 ; i < kTimeStamps.length; i ++){
      indexOfTime.add(findIndexOf(day, kTimeStamps[i]));
    }
    return indexOfTime;
  }


  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    var path = directory.path;
    return path;
  }

  Future<DataFrame> readCsv(String date) async {

    var localPath = await _localPath;
    debugPrint("Data Reader : readCSV : ${localPath}/sensorData/${date}_sensor.csv");
    final df = await DataFrame.fromCsv("${localPath}/sensorData/${date}_sensor.csv");
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