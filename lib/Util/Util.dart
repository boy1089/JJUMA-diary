import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';
import 'package:matrix2d/matrix2d.dart';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:jjuma.d/Util/Util.dart';
import 'dart:math';
import 'dart:io';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:exif/exif.dart';
import "package:jjuma.d/Location/coordinate.dart";
import 'package:photo_manager/photo_manager.dart';

import 'DateHandler.dart';

const bool kDebugMode = !kReleaseMode && !kProfileMode;

double maximumSizeOfScatter = 50.0;
double minimumSizeOfScatter = 1.0;

Size sizeOfChart = const Size(800, 800);

Size standardScreenSize = const Size(411.4, 707.4);

Size physicalScreenSize = window.physicalSize / window.devicePixelRatio;
double physicalWidth = physicalScreenSize.width;
double physicalHeight = physicalScreenSize.height;

const kSensorPlotRadius = 1.0;
const kPhotoPlotRadius = 2.0;
const kDataReaderSubsampleFactor = 50;


const kDefaultPolarPlotSize = 250.0;
const kSecondPolarPlotSize = kDefaultPolarPlotSize * 1.3;
const kThirdPolarPlotSize = kDefaultPolarPlotSize * 2;


int a = 255;

// List<Color> colorsLp = Color.lerp(Colors.deepOrange, Colors.blueAccent, 2.0);

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


double floorDistance(double? distance) {
  if (distance == null) return 4;
  if (distance > 50) return 0;
  if (distance > 20) return 1;
  if (distance > 5) return 2;
  if (distance > 2) return 3;
  return 4;
}

int floorNumberOfImages(int numberOfImages){
  if (numberOfImages > 50) return 0;
  if (numberOfImages > 30) return 1;
  if (numberOfImages > 10) return 2;
  if (numberOfImages > 2) return 3;
  return 4;

}

List<List<dynamic>> transpose(list) {
  // print("transpose, $list");
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

class AllowMultipleGestureRecognizer extends TapGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    print("reject pointer : $pointer");
    acceptGesture(pointer);
  }
}

class AllowMultipleGestureRecognizer2 extends PanGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    print("pointer is dragging : $pointer");
    acceptGesture(pointer);
  }
}

double calculateTapAngle(Offset, referencePosition, referenceAngle) {
  double dx = Offset.dx;
  double dy = Offset.dy;

  var angle =
      atan2(dy / sqrt(dx * dx + dy * dy), dx / sqrt(dx * dx + dy * dy)) /
          (2 * pi);
  return angle;
}

Offset calculateTapPositionRefCenter(details, reference, layout) {
  bool isZoomIn = false;
  var dx = details.globalPosition.dx - layout['graphCenter'][isZoomIn].dx;
  var dy =
      -1 * (details.globalPosition.dy - layout['graphCenter'][isZoomIn].dy);
  return Offset(dx, dy.toDouble());
}

Future<List> openFile(filePath) async {
  File f = File(filePath);
  final input = f.openRead();
  final fields = await input
      .transform(utf8.decoder)
      .transform(const CsvToListConverter(eol: '\n'))
      .toList();
  // print(slice(fields, [0, fields.shape[0]], [1]));
  return fields;
}

Future getExifInfoOfFile(String file) async {
  // var bytes = await File(file).readAsBytes();
  var byte2 = await File(file).open(mode: FileMode.read);
  // print("byte : ${bytes}");
  // var data = await readExifFromBytes(bytes.sublist(0, 2000));
  var data = await readExifFromBytes(await byte2.read(2000));
  byte2.close();

  // print("data : $data");

  String? dateInExif = null;
  List<String> keys = data.keys.toList();
  List<String> keysOfDateTime = keys.where((element) {
    return (element.contains("DateTime"));
  }).toList();

  for (int i = 0; i < keysOfDateTime.length; i++) {
    String key = keysOfDateTime.elementAt(i);
    IfdTag? datetimeInExif = data[key];
    if (datetimeInExif != null) {
      dateInExif = data[key].toString().replaceAll(":", "");
      break;
    }
    // print("step4 ${stopwatch.elapsed}");
  }


  Coordinate? coordinate = Coordinate(
      convertTagToValue(data['GPS GPSLatitude']) ,
      convertTagToValue(data['GPS GPSLongitude']));
  if (coordinate.latitude == null) coordinate = null;

  int latRef = convertGPSRefToInt(data['GPS GPSLatitudeRef']?.printable);
  int longRef = convertGPSRefToInt(data['GPS GPSLongitudeRef']?.printable);

  coordinate!.setLatRef(latRef);
  coordinate!.setLongRef(longRef);

  return [dateInExif, coordinate];
}

Future getExifInfoOfFile_ios(AssetEntity assetEntity) async {
  String? dateInExif = null;

  dateInExif = formatDatetime(assetEntity.createDateTime);

  Coordinate? coordinate =
      Coordinate(assetEntity.latitude, assetEntity.longitude);
  if (coordinate.latitude == null) coordinate = null;
  if( assetEntity.latitude == 0.0) coordinate = null;
  return [dateInExif, coordinate];
}

double? convertTagToValue(tag) {
  if (tag == null) return null;
  print("tag : ${tag}");
  List values = tag.printable
      .replaceAll("[", "")
      .replaceAll("]", "")
      .replaceAll(" ", "")
      .split(',');

  double value = double.parse(values[0]) +
      double.parse(values[1]) / 60 +
      double.parse(values[2].split('/')[0]) / 1e6 / 3600;
  return value;
}

int convertGPSRefToInt(String? ref){
  if(ref == null) return 1;
  if(ref == 'N') return 1;
  if(ref == 'E')  return 1;
  return -1;
}