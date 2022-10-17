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

var physicalScreenSize = window.physicalSize / window.devicePixelRatio;
var physicalWidth = physicalScreenSize.width;
var physicalHeight = physicalScreenSize.height;

const kSensorPlotRadius = 1.0;
const kPhotoPlotRadius = 2.0;
const kDataReaderSubsampleFactor = 50;

const longitude_home = 126.7209;
const latitude_home = 37.3627;
const distance_threshold_home = 0.02;

const kDefaultPolarPlotSize = 250.0;
const kSecondPolarPlotSize = kDefaultPolarPlotSize * 1.3;
const kThirdPolarPlotSize = kDefaultPolarPlotSize * 1.5;

const event_color_goingOut = Colors.red;
const event_color_backHome = Colors.blue;
const path_phonecall = '/sdcard/Music/TPhoneCallRecords';

List<List<dynamic>> dummyData = [
  [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
  [0.0, 1.5, 0.0, 0.0, 0.0, 0.0, 0.0],
  [2.0, 1.5, 0.0, 0.0, 0.0, 0.0, 0.0],
  [4.0, 1.5, 0.0, 0.0, 0.0, 0.0, 0.0],
  [6.0, 1.5, 0.0, 0.0, 0.0, 0.0, 0.0],
  [8.0, 1.5, 0.0, 0.0, 0.0, 0.0, 0.0],
  [10.0, 1.5, 0.0, 0.0, 0.0, 0.0, 0.0],
  [12.0, 1.5, 0.0, 0.0, 0.0, 0.0, 0.0],
  [14.0, 1.5, 0.0, 0.0, 0.0, 0.0, 0.0],
  [16.0, 1.5, 0.0, 0.0, 0.0, 0.0, 0.0],
  [18.0, 1.5, 0.0, 0.0, 0.0, 0.0, 0.0],
];

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

List<List<double>> dummyPhotoData = [
  [0, kPhotoPlotRadius],
  [8, kPhotoPlotRadius],
  [10, kPhotoPlotRadius],
  [18, kPhotoPlotRadius],
  [21, kPhotoPlotRadius],
];

/***
 * when reading csv file with open file, resulting list is
 * [[time, column_a, column_b],
 * [2022~, 0.0, link234], ...]
 * we need to i) convert timestamp to hour, ii) select column, iii) put dummy column for radius, iv) handling empty list, v) handling exceptions
 * modify functions handles such cases.
 *
 * openFile -> convertTime -> get the
 */

//coverage : photoData, photoResponse, sensorData
//photoDAta : time, link
//sensorData : time, longitude, latitude, accelX, accelY, accelZ, light, temperature, proximity, humidity
// or time, longitude, latitude, accelX, accelY, accelZ

//result : time(int), values ~~, dummy for radial plot

List modifyListForPlot(List fields,
    {bool filterTime = false, bool executeTranspose = false}) {
  //when empty list is input, return list with default value when
  if (fields.length == 1) {
    // return List<List<dynamic>>.generate(fields[0].length, (int index) => [0, 1]);
    List<List<dynamic>> dummyData = [
      [0, "https://img.icons8.com/ios-filled/344/no-image.png", 3]
    ];
    return dummyData;
  }

  //transpose data if needed
  if (executeTranspose) {
    fields = transpose(fields);
  }

  //filter the value
  List listFiltered = fields;
  if (filterTime) listFiltered = filterList(fields);

  // convert time string or timestamp into int
  List result = convertStringTimeToInt(listFiltered);
  print("result shape : ${result.shape}");
  List listRadial = List<List<double>>.generate(
      result.shape[0], (int index) => [kThirdPolarPlotSize]);
  result = Matrix2d().concatenate(result, listRadial, axis: 1);
  return result;
}

List filterList(List input) {
  //create empty output with same shape as input
  List output = [];
  for (int i = 0; i < input.length; i++) {
    try {
      //exclude if filename is not in format of yyyyMMdd_HHmmSS
      if (input[i][0][8] != "_")continue;
      if (input[i][0].contains("t"))continue;

      output.add(input[i]);
    } catch (e) {
      print(e);
    }
  }

  //insert the name of columns
  output.insert(0, input[0]);
  print("filterList result: ${output}");
  return output;
}

List<List<dynamic>> transpose(list) {
  print("transpose, $list");
  if (list.length == 0) return [[], []];

  int columnNumber = list.elementAt(0).length;
  int rowNumber = list.length;
  List<List<dynamic>> output = [];

  for (int i = 0; i < columnNumber; i++) {
    output.add([]);
  }

  for (int i = 0; i < columnNumber; i++) {
    for (int j = 0; j < rowNumber; j++) {
      output.elementAt(i).insert(j, list.elementAt(j).elementAt(i));
    }
  }
  return output;
}

List convertStringTimeToInt(List fields) {
  List listTime = slice(fields, [1, fields.shape[0]], [0, 1]).flatten;
  listTime = List<List<double>>.generate(listTime.length,
      (int index) => [convertStringTimeToDouble(listTime[index])]);

  List listValues = slice(fields, [1, fields.shape[0]], [1, fields.shape[1]]);

  List output = const Matrix2d().concatenate(listTime, listValues, axis: 1);
  return output;
}

double convertStringTimeToDouble(String time) {
  var timeSplit;
  if (time.contains(":")) {
    timeSplit = time.substring(11, 19).split(':');
  } else {
    timeSplit = [
      time.substring(9, 11),
      time.substring(11, 13),
      time.substring(13, 15)
    ];
  }
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
