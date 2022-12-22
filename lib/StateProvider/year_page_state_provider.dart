import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lateDiary/Data/info_from_file.dart';
import 'package:lateDiary/Util/DateHandler.dart';
import 'package:lateDiary/Util/Util.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../Data/data_manager_interface.dart';
import '../Location/coordinate.dart';
import '../pages/YearPage/year_page_screen2.dart';

import 'package:scidart/numdart.dart';
import 'dart:core';

enum ImportanceFilter { memorable, casual, none }

List positionExpanded = List.generate(372, (index) {
  double day = index.toDouble();
  double week = day / 7.ceil();
  double weekday = day % 7;
  double radius = (weekday + 3) / 11 * 1.2;
  double angle = week / 52 * 2 * pi;

  double xLocation = radius * cos(angle - pi / 2);
  double yLocation = radius * sin(angle - pi / 2);
  return [xLocation, yLocation];
});

List positionNotExpanded = List.generate(372, (index) {
  double day = index.toDouble();
  double week = day / 7.ceil();
  double weekday = day % 7;
  double angle = day / 365 * 2 * pi;
  double xLocation = 1 * cos(angle - pi / 2);
  double yLocation = 1 * sin(angle - pi / 2);
  return [xLocation, yLocation];
});

enum LocationFilter {
  trip,
  none,
  home,
}

int yearRange = 20;

class YearPageStateProvider with ChangeNotifier {
  int index = 0;
  double zoomInAngle = 0.0;
  bool isZoomIn = false;
  List<dynamic> dataForChartList = [];
  List<dynamic> dataForChartList2 = [];
  //TODO remove availableDates
  List<String> availableDates = [];
  int importanceFilterIndex = ImportanceFilter.none.index;
  int locationFilterIndex = LocationFilter.none.index;

  List<List<dynamic>> dataForChart = [];
  Map dataForChart2_modified = {};
  Map<int, Map<String, List>> dataForChart2 = {};
  int? expandedYear = null;
  Map<int, Coordinate?>? medianCoordinates = {};
  Coordinate? medianCoordinate;
  double? photoViewScale = 1;
  int? highlightedYear = null;

  void setHighlightedYear(int? year) {
    highlightedYear = year;
    notifyListeners();
  }

  DataManagerInterface dataManager;
  YearPageStateProvider(this.dataManager) {
    // updateData();
    // modifyData();
  }
  Future<void> updateData() async {
    print("update Data For YearPage StateProvider");
    dataForChart = [];
    dataForChart2 = {};
    List<Coordinate> coordinates = [];

    for (MapEntry entry in dataManager.infoFromFiles.entries) {
      if (entry.value.datetime == null) continue;
      DateTime datetime = entry.value.datetime;
      Coordinate? coordinate = entry.value.coordinate;
      int year = datetime.year;

      if (dataForChart2[year] == null) dataForChart2[year] = {};

      if (dataForChart2[year]![formatDate(datetime)] == null)
        dataForChart2[year]![formatDate(datetime)] = [[]];

      dataForChart2[year]![formatDate(datetime)]![0].add(entry);

      if (coordinate == null) continue;
      if (coordinate!.latitude == null) continue;

      if (dataForChart2[year]![formatDate(datetime)]!.length == 2) {
        dataForChart2[year]![formatDate(datetime)]![1] = coordinate;
        continue;
      }

      dataForChart2[year]![formatDate(datetime)]!.add(coordinate);

      if ((coordinate != null) && (coordinate.longitude != null))
        coordinates.add(coordinate);
    }

    dataForChart2 = Map.fromEntries(
        dataForChart2.entries.toList()
          ..sort((e1, e2) => e2.key.compareTo(e1.key)))
      ..removeWhere((key, value) => key > DateTime.now().year);

    getMedianCoordinate(coordinates);

    notifyListeners();
  }

  static Future<List> updateData_static(List input) async {
    print("static update Data For YearPage StateProvider");
    Map<dynamic, InfoFromFile> infoFromFiles = input[0];
    Map<int, Map<String, List>> dataForChart2 = {};
    List<Coordinate> coordinates = [];

    for (MapEntry entry in infoFromFiles.entries) {
      if (entry.value.datetime == null) continue;
      DateTime datetime = entry.value.datetime;
      Coordinate? coordinate = entry.value.coordinate;
      int year = datetime.year;

      if (dataForChart2[year] == null) dataForChart2[year] = {};

      if (dataForChart2[year]![formatDate(datetime)] == null)
        dataForChart2[year]![formatDate(datetime)] = [[]];

      dataForChart2[year]![formatDate(datetime)]![0].add(entry);

      if (coordinate == null) continue;
      if (coordinate!.latitude == null) continue;

      if (dataForChart2[year]![formatDate(datetime)]!.length == 2) {
        dataForChart2[year]![formatDate(datetime)]![1] = coordinate;
        continue;
      }

      dataForChart2[year]![formatDate(datetime)]!.add(coordinate);

      if ((coordinate != null) && (coordinate.longitude != null))
        coordinates.add(coordinate);
    }

    dataForChart2 = Map.fromEntries(
        dataForChart2.entries.toList()
          ..sort((e1, e2) => e2.key.compareTo(e1.key)))
      ..removeWhere((key, value) => key > DateTime.now().year);

    Coordinate? median = getMedianCoordinate_static(coordinates);

    return [dataForChart2, median];

  }



  Future<void> updateProvider_compute() async {
    if((dataManager.infoFromFiles==null)|(dataManager.infoFromFiles=={})) return;
    var result = await compute(updateData_static, [dataManager.infoFromFiles]);
    dataForChart2 = result[0];
    medianCoordinate = result[1];

    var result2 = await compute(modifyData_static, [dataForChart2, medianCoordinate, physicalWidth]);
    dataForChart2_modified = result2[0];

    notifyListeners();
  }


  void getMedianCoordinate(List<Coordinate> coordinates) {
    if (coordinates.length == 0) return;

    medianCoordinate = Coordinate(
        median(Array(List<double>.generate(
            coordinates.length,
            (index) => double.parse(
                coordinates[index].latitude!.toStringAsFixed(3))))),
        median(
          Array(List<double>.generate(
              coordinates.length,
              (index) => double.parse(
                  coordinates[index].longitude!.toStringAsFixed(3)))),
        ));
  }


  static Coordinate? getMedianCoordinate_static(List<Coordinate> coordinates) {
    if (coordinates.length == 0) return null;

    Coordinate medianCoordinate = Coordinate(
        median(Array(List<double>.generate(
            coordinates.length,
                (index) => double.parse(
                coordinates[index].latitude!.toStringAsFixed(3))))),
        median(
          Array(List<double>.generate(
              coordinates.length,
                  (index) => double.parse(
                  coordinates[index].longitude!.toStringAsFixed(3)))),
        ));
    return medianCoordinate;
  }


  Future<void> modifyData() async {
    print("modify data of yearStateProvider");
    for (int i = 0; i < dataForChart2.length; i++) {
      int year = dataForChart2.keys.elementAt(i);
      var data = dataForChart2[year];

      dataForChart2_modified[year] = List.generate(data!.length, (index) {
        String date = data.keys.elementAt(index);
        DateTime datetime = DateTime(year, int.parse(date.substring(4, 6)),
            int.parse(date.substring(6, 8)));
        int indexOfDate = datetime.difference(DateTime(year)).inDays +
            DateTime(year).weekday -
            1;

        double xLocationExpanded = positionExpanded[indexOfDate][0];
        double yLocationExpanded = positionExpanded[indexOfDate][1];

        xLocationExpanded = (1.0) * xLocationExpanded;
        yLocationExpanded = (1.0) * yLocationExpanded;

        yLocationExpanded = yLocationExpanded + 0.95;

        double xLocationNotExpanded = positionNotExpanded[indexOfDate][0];
        double yLocationNotExpanded = positionNotExpanded[indexOfDate][1];

        xLocationNotExpanded = (1 - i * 0.1) * xLocationNotExpanded;
        yLocationNotExpanded = (1 - i * 0.1) * yLocationNotExpanded;
        yLocationNotExpanded = yLocationNotExpanded + 0.95;

        int numberOfImages = data[date]?[0].length ?? 1;
        Coordinate? coordinate = data[date]!.length > 1
            ? data[date]![1]
            : Coordinate(
                medianCoordinate!.latitude, medianCoordinate!.longitude);

        double diffInCoord =
            (coordinate!.longitude! - medianCoordinate!.longitude!).abs();

        diffInCoord = diffInCoord > 215 ? 215 : diffInCoord;

        int locationClassification = 4;
        // if (diffInCoord < 10) locationClassification = 4;
        if (diffInCoord < 5) locationClassification = 3;
        if (diffInCoord < 1) locationClassification = 2;
        if (diffInCoord < 0.1) locationClassification = 1;
        if (diffInCoord < 0.01) locationClassification = 0;

        Color color = (coordinate == null) | (coordinate.longitude == null)
            ? Colors.grey.withAlpha(100)
            : HSLColor.fromAHSL(
                    0.5, 215 - locationClassification * 50, 67 / 100, 50 / 100)
                .toColor();

        double size = numberOfImages / 5.toDouble();
        size = size < 50 ? size : 50;
        List entries = data[date]![0];

        double leftExpanded = xLocationExpanded * (physicalWidth) / 2 +
            (sizeOfChart.width) / 2 -
            size / 2;
        double topExpanded = yLocationExpanded * physicalWidth / 2 +
            physicalWidth / 2 -
            size / 2;
        double leftNotExpanded = xLocationNotExpanded * (physicalWidth) / 2 +
            (sizeOfChart.width) / 2 -
            size / 2;
        double topNotExpanded = yLocationNotExpanded * physicalWidth / 2 +
            physicalWidth / 2 -
            size / 2;

        double leftExpandedExtra = positionNotExpanded[indexOfDate][0] *
                (1.5 - 0.05 * i) *
                (physicalWidth) /
                2 +
            (sizeOfChart.width) / 2 -
            size / 2;

        double topExpandedExtra =
            (positionNotExpanded[indexOfDate][1] * (1.5 - 0.05 * i) + 0.95) *
                    physicalWidth /
                    2 +
                physicalWidth / 2 -
                size / 2;
        // return [xLocation, yLocation, size, color, entries];
        return [
          leftExpanded,
          topExpanded,
          leftNotExpanded,
          topNotExpanded,
          leftExpandedExtra,
          topExpandedExtra,
          size,
          color,
          entries,
          date
        ];
      });
    }
    // dataForChart2_modified = Map.fromEntries(dataForChart2_modified.entries.toList()..sort((e1, e2)=>e2.key.compareTo(e1.key)));
    notifyListeners();
  }

  static Future<List> modifyData_static(List input) async {
    print("static modify data of yearStateProvider");

    Map dataForChart2 = input[0];
    Coordinate? medianCoordinate = input[1];
    double physicalWidth = input[2];
    Map dataForChart2_modified = {};

    for (int i = 0; i < dataForChart2.length; i++) {
      int year = dataForChart2.keys.elementAt(i);
      var data = dataForChart2[year];

      dataForChart2_modified[year] = List.generate(data!.length, (index) {

        List positionExpanded = List.generate(372, (index) {
          double day = index.toDouble();
          double week = day / 7.ceil();
          double weekday = day % 7;
          double radius = (weekday + 3) / 11 * 1.2;
          double angle = week / 52 * 2 * pi;

          double xLocation = radius * cos(angle - pi / 2);
          double yLocation = radius * sin(angle - pi / 2);
          return [xLocation, yLocation];
        });

        List positionNotExpanded = List.generate(372, (index) {
          double day = index.toDouble();
          double week = day / 7.ceil();
          double weekday = day % 7;
          double angle = day / 365 * 2 * pi;
          double xLocation = 1 * cos(angle - pi / 2);
          double yLocation = 1 * sin(angle - pi / 2);
          return [xLocation, yLocation];
        });



        String date = data.keys.elementAt(index);
        DateTime datetime = DateTime(year, int.parse(date.substring(4, 6)),
            int.parse(date.substring(6, 8)));
        int indexOfDate = datetime.difference(DateTime(year)).inDays +
            DateTime(year).weekday -
            1;

        double xLocationExpanded = positionExpanded[indexOfDate][0];
        double yLocationExpanded = positionExpanded[indexOfDate][1];

        xLocationExpanded = (1.0) * xLocationExpanded;
        yLocationExpanded = (1.0) * yLocationExpanded;

        yLocationExpanded = yLocationExpanded + 0.95;

        double xLocationNotExpanded = positionNotExpanded[indexOfDate][0];
        double yLocationNotExpanded = positionNotExpanded[indexOfDate][1];

        xLocationNotExpanded = (1 - i * 0.1) * xLocationNotExpanded;
        yLocationNotExpanded = (1 - i * 0.1) * yLocationNotExpanded;
        yLocationNotExpanded = yLocationNotExpanded + 0.95;

        int numberOfImages = data[date]?[0].length ?? 1;
        Coordinate? coordinate = data[date]!.length > 1
            ? data[date]![1]
            : Coordinate(
            medianCoordinate!.latitude, medianCoordinate!.longitude);

        double diffInCoord =
        (coordinate!.longitude! - medianCoordinate!.longitude!).abs();

        diffInCoord = diffInCoord > 215 ? 215 : diffInCoord;

        int locationClassification = 4;
        // if (diffInCoord < 10) locationClassification = 4;
        if (diffInCoord < 5) locationClassification = 3;
        if (diffInCoord < 1) locationClassification = 2;
        if (diffInCoord < 0.1) locationClassification = 1;
        if (diffInCoord < 0.01) locationClassification = 0;

        Color color = (coordinate == null) | (coordinate.longitude == null)
            ? Colors.grey.withAlpha(100)
            : HSLColor.fromAHSL(
            0.5, 215 - locationClassification * 50, 67 / 100, 50 / 100)
            .toColor();

        double size = numberOfImages / 5.toDouble();
        size = size < 50 ? size : 50;
        List entries = data[date]![0];

        double leftExpanded = xLocationExpanded * (physicalWidth) / 2 +
            (sizeOfChart.width) / 2 -
            size / 2;
        double topExpanded = yLocationExpanded * physicalWidth / 2 +
            physicalWidth / 2 -
            size / 2;
        double leftNotExpanded = xLocationNotExpanded * (physicalWidth) / 2 +
            (sizeOfChart.width) / 2 -
            size / 2;
        double topNotExpanded = yLocationNotExpanded * physicalWidth / 2 +
            physicalWidth / 2 -
            size / 2;

        double leftExpandedExtra = positionNotExpanded[indexOfDate][0] *
            (1.5 - 0.05 * i) *
            (physicalWidth) /
            2 +
            (sizeOfChart.width) / 2 -
            size / 2;

        double topExpandedExtra =
            (positionNotExpanded[indexOfDate][1] * (1.5 - 0.05 * i) + 0.95) *
                physicalWidth /
                2 +
                physicalWidth / 2 -
                size / 2;
        // return [xLocation, yLocation, size, color, entries];
        return [
          leftExpanded,
          topExpanded,
          leftNotExpanded,
          topNotExpanded,
          leftExpandedExtra,
          topExpandedExtra,
          size,
          color,
          entries,
          date
        ];
      });
    }
    // dataForChart2_modified = Map.fromEntries(dataForChart2_modified.entries.toList()..sort((e1, e2)=>e2.key.compareTo(e1.key)));

    return [dataForChart2_modified];
  }
  void setPhotoViewScale(double photoViewScale) {
    this.photoViewScale = photoViewScale;
    notifyListeners();
  }

  void setAvailableDates(int year) {
    availableDates = dataManager.summaryOfPhotoData.keys.where((element) {
      return element.substring(0, 4) == year.toString();
    }).toList();
    availableDates.sort();
  }

  void setZoomInRotationAngle(angle) {
    // print("provider set zoomInAngle to $angle");
    zoomInAngle = angle;
    notifyListeners();
  }

  void setZoomInState(isZoomIn) {
    print("provider set isZoomIn to $isZoomIn");
    this.isZoomIn = isZoomIn;
    notifyListeners();
  }

  void setExpandedYear(int? year) {
    expandedYear = year;
    notifyListeners();
  }

  @override
  void dispose() {
    print("yearPageSTateProvider disposed");
  }
}
