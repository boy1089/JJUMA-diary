
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:matrix2d/matrix2d.dart';
const bool kDebugMode = !kReleaseMode && !kProfileMode;

List<String> kTimeStamps = [
  '00', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17',
'18', '19', '20', '21', '22', '23'
];


List<String> kTimeStamps2hour = [
  '00', '02',  '04',  '06', '08', '10', '12', '14', '16',
  '18', '20', '22',
];
List<String> kTimeStamps_filtered = [
  '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17',
  '18', '19', '20', '21', '22', '23'
];


List<String> kTimeStamps2hour_filtered = [
  '06', '08', '10', '12', '14', '16',
  '18', '20', '22',
];

const longitude_home = 126.7209;
const latitude_home = 37.3627;
const distance_threshold_home = 0.02;

const event_color_goingOut = Colors.red;
const event_color_backHome = Colors.blue;
const path_phonecall = '/sdcard/Music/TPhoneCallRecords';

int a = 10;
List<Color> get colorsHotCold => [
  Color.fromARGB(a, 50, 0, 0),
  Color.fromARGB(a, 40, 0, 0),
  Color.fromARGB(a, 30, 0, 0),
  Color.fromARGB(a, 20, 0, 0),
  Color.fromARGB(a, 10, 0, 0),
  Color.fromARGB(a, 0, 0, 0),
  Color.fromARGB(a, 0, 0, 10),
  Color.fromARGB(a, 0, 0, 20),
  Color.fromARGB(a, 0, 0, 30),
  Color.fromARGB(a, 0, 0, 40),
];

List<dynamic> convertStringTimeToInt(List fields) {
  debugPrint(fields.toString());
  List listTime = slice(fields, [1, fields.shape[0]], [0, 1]).flatten;

  listTime = List<List<double>>.generate(listTime.length,
          (int index) => [convertStringTimeToDouble(listTime[index])]);
  List listSensor = slice(fields, [1, fields.shape[0]], [1, 5]);
  debugPrint(listTime.shape.toString());
  debugPrint(listSensor.shape.toString());
  List list = const Matrix2d().concatenate(listTime, listSensor, axis: 1);

  return list;
}

double convertStringTimeToDouble(String time) {
  List<String> timeSplit = time.substring(11, 19).split(':');
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
