import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:path_provider/path_provider.dart';
import 'package:matrix2d/matrix2d.dart';
import 'dart:ui';
const bool kDebugMode = !kReleaseMode && !kProfileMode;

List<String> kTimeStamps = [
  '00',
  '01',
  '02',
  '03',
  '04',
  '05',
  '06',
  '07',
  '08',
  '09',
  '10',
  '11',
  '12',
  '13',
  '14',
  '15',
  '16',
  '17',
  '18',
  '19',
  '20',
  '21',
  '22',
  '23'
];

List<String> kTimeStamps2hour = [
  '00',
  '02',
  '04',
  '06',
  '08',
  '10',
  '12',
  '14',
  '16',
  '18',
  '20',
  '22',
];
List<String> kTimeStamps_filtered = [
  '06',
  '07',
  '08',
  '09',
  '10',
  '11',
  '12',
  '13',
  '14',
  '15',
  '16',
  '17',
  '18',
  '19',
  '20',
  '21',
  '22',
  '23'
];

List<String> kTimeStamps2hour_filtered = [
  '06',
  '08',
  '10',
  '12',
  '14',
  '16',
  '18',
  '20',
  '22',
];

const kSensorPlotRadius = 1.0;
const kPhotoPlotRadius = 2.0;
const kDataReaderSubsampleFactor = 50;

const longitude_home = 126.7209;
const latitude_home = 37.3627;
const distance_threshold_home = 0.02;

const kDefaultPolarPlotSize = 250.0;
const kSecondPolarPlotSize = kDefaultPolarPlotSize*1.3;
const kThirdPolarPlotSize = kDefaultPolarPlotSize*1.5;

const event_color_goingOut = Colors.red;
const event_color_backHome = Colors.blue;
const path_phonecall = '/sdcard/Music/TPhoneCallRecords';

int a = 50;
List<Color> get colorsHotCold => [
      Color.fromARGB(a, 100, 20, 0),
      Color.fromARGB(a, 80, 20, 0),
      Color.fromARGB(a, 60, 20, 0),
      Color.fromARGB(a, 40, 20, 0),
      Color.fromARGB(a, 20, 20, 0),
      Color.fromARGB(a, 0, 20, 0),
      Color.fromARGB(a, 0, 20, 20),
      Color.fromARGB(a, 0, 20, 40),
      Color.fromARGB(a, 0, 20, 60),
      Color.fromARGB(a, 0, 20, 80),
    ];

List<List<double>> dummyPhotoData =
[[0, kPhotoPlotRadius],
[8, kPhotoPlotRadius],
  [10, kPhotoPlotRadius],
  [18, kPhotoPlotRadius],
  [21, kPhotoPlotRadius],
];



List modifyPhotoResponseForPlot(List fields){
  List listTimeConverted = convertStringTimeToInt2(fields);
  print(listTimeConverted);
  print(listTimeConverted.shape[1]);

  List listRadial = List<double>.generate(
    listTimeConverted.shape[1], (int index) => kThirdPolarPlotSize);
  print("type of List Time converted : ${listTimeConverted.runtimeType}");
  listTimeConverted.add(listRadial);
  List listMerged = listTimeConverted;
  return listMerged;
}


List<List<dynamic>> transpose(list){

  int columnNumber = list.elementAt(0).length;
  int rowNumber = list.length;
  List<List<dynamic>> output = [];

  for(int i = 0; i < columnNumber; i++){
    output.add([]);
  }

  for(int i = 0; i < columnNumber; i++){
    for(int j = 0; j<rowNumber; j++){
      output.elementAt(i).insert(j, list.elementAt(j).elementAt(i));
    }
  }
  return output;
}

List modifySensorDataForPlot(List fields) {
  List listTimeConverted = convertStringTimeToInt(fields);
  List listRadial = List<List<double>>.generate(
      listTimeConverted.shape[0], (int index) => [kSensorPlotRadius]);
  List listMerged =
      Matrix2d().concatenate(listTimeConverted, listRadial, axis: 1);
  return listMerged;
}

List<dynamic> convertStringTimeToInt(List fields) {
  List listTime = slice(fields, [1, fields.shape[0]], [0, 1]).flatten;
  listTime = List<List<double>>.generate(listTime.length,
      (int index) => [convertStringTimeToDouble(listTime[index])]);

  List listSensor = slice(fields, [1, fields.shape[0]], [1, fields.shape[1]]);
  List list = const Matrix2d().concatenate(listTime, listSensor, axis: 1);
  return list;
}

List convertStringTimeToInt2(List fields) {
  List listTime = fields[0];
  listTime = List<List<double>>.generate(listTime.length,
          (int index) => [convertStringTimeToDouble(listTime[index])]).flatten;

  List listPhotoLinks = fields[1];
  List<List<dynamic>> result = [listTime, listPhotoLinks];
  return result;
}

var physicalScreenSize = window.physicalSize / window.devicePixelRatio;
var physicalWidth = physicalScreenSize.width;
var physicalHeight = physicalScreenSize.height;


double convertStringTimeToDouble(String time) {
  var timeSplit;
  if (time.contains(":")) {
    timeSplit = time.substring(11, 19).split(':');
  } else{
    timeSplit = [time.substring(9, 11), time.substring(11, 13),time.substring(13, 15)];
  }
  print(timeSplit);
  double timeDouble = double.parse(timeSplit[0]) +
      double.parse(timeSplit[1]) / 60.0 +
      double.parse(timeSplit[2]) / 3600.0;
  return timeDouble;
}

List slice(List<dynamic> array, List<int> row_index,
    [List<int>? column_index]) {
  var result = [];
  var arr = array.map((e) => e is List ? e : [e]).toList();
  try {
    if (row_index.length > 2) {
      throw Exception(
          'row_index only containing the elements between start and end.');
    }
    int rowMin = row_index[0];
    int rowMax = row_index[1];
    int counter = 0;
    for (var row in arr) {
      if (rowMin <= counter && counter < rowMax) {
        if (column_index != null && column_index.length > 1) {
          result.add(row.getRange(column_index[0], column_index[1]).toList());
        } else if (column_index == null) {
          result.add(row);
        } else {
          if (result.isEmpty) {
            result = [row[column_index[0]]];
          } else {
            result.add(row[column_index[0]]);
          }
        }
      }
      counter++;
    }
    return result;
  } catch (e) {
    throw Exception(e);
  }
}
