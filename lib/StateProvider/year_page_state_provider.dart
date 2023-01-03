// TODO Implement this library.import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jjuma.d/Data/info_from_file.dart';
import 'package:jjuma.d/Util/DateHandler.dart';
import 'package:jjuma.d/Util/Util.dart';

import '../Data/data_manager_interface.dart';
import '../Location/coordinate.dart';

import 'package:scidart/numdart.dart';
import 'dart:core';
import 'package:jjuma.d/Util/global.dart' as global;

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
  double angle = day / 365 * 2 * pi;
  double xLocation = 1 * cos(angle - pi / 2);
  double yLocation = 1 * sin(angle - pi / 2);
  return [xLocation, yLocation];
});

List<double> hueList = [215.0, 126.0, 63.0, 0.0, 281.0];
List<Color> colorList = [
  const Color(0xFF2A2A2A),
  const Color(0xFF2A4D7F),
  const Color(0xFF2A7F32),
  const Color(0xFFffbf00),
];

List<Color> colorList2 = [
  const Color(0xFF2a71d5),
  const Color(0xFF2ad53b),
  const Color(0xFFffbf00),
  const Color(0xFFd52a2a),
  const Color(0xFF9f2ad5),
  const Color(0xFF2A2A2A),
];


// const Color(0xFFccd52a),

enum LocationFilter {
  trip,
  none,
  home,
}

class YearPageStateProvider with ChangeNotifier {
  bool isZoomIn = false;

  Map dataForChart2_modified = {};
  Map<int, Map<String, List>> dataForChart2 = {};
  Map<int, Coordinate?>? medianCoordinates = {};
  Map<int, int> numberOfImages = {};
  Coordinate? medianCoordinate;

  int? expandedYear = DateTime.now().year;
  int maxNumOfYearChart = 9;
  int? highlightedYear;
  List listOfYears = [];

  double angle = 0.0;

  DataManagerInterface dataManager;
  YearPageStateProvider(this.dataManager);


  static Future<List> updateData_static(List input) async {
    print("static update Data For YearPage StateProvider");
    Map<dynamic, InfoFromFile> infoFromFiles = input[0];
    Map<int, Map<String, List>> dataForChart2 = {};
    List<Coordinate> coordinates = [];
    Map<int, int> numberOfImages = {};

    for (MapEntry entry in infoFromFiles.entries) {
      if (entry.value.datetime == null) continue;
      DateTime datetime = entry.value.datetime;
      Coordinate? coordinate = entry.value.coordinate;
      int year = datetime.year;

      if (dataForChart2[year] == null) dataForChart2[year] = {};
      if (numberOfImages[year] == null) {
        numberOfImages[year] = 1;
      } else {
        numberOfImages[year] = numberOfImages[year]! + 1;
      }

      if (dataForChart2[year]![formatDate(datetime)] == null) {
        dataForChart2[year]![formatDate(datetime)] = [[]];
      }

      dataForChart2[year]![formatDate(datetime)]![0].add(entry);

      if (coordinate == null) continue;
      if (coordinate.latitude == null) continue;

      if (dataForChart2[year]![formatDate(datetime)]!.length == 2) {
        dataForChart2[year]![formatDate(datetime)]![1] = coordinate;
        continue;
      }

      dataForChart2[year]![formatDate(datetime)]!.add(coordinate);

      if ((coordinate != null) && (coordinate.longitude != null)) {
        coordinates.add(coordinate);
      }
    }

    dataForChart2 = Map.fromEntries(
        dataForChart2.entries.toList()
          ..sort((e1, e2) => e2.key.compareTo(e1.key)))
      ..removeWhere((key, value) => key > DateTime.now().year);

    numberOfImages = Map.fromEntries(
        numberOfImages.entries.toList()
          ..sort((e1, e2) => e2.key.compareTo(e1.key)))
      ..removeWhere((key, value) => key > DateTime.now().year);

    Coordinate? median = getMedianCoordinate_static(coordinates);

    return [dataForChart2, median, numberOfImages];
  }

  Future<void> updateProvider_compute() async {
    print("updateProvider..");
    if ((dataManager.infoFromFiles == null) |
        (dataManager.infoFromFiles.isEmpty)) {
      print("updateProvider.. no data");
      return;
    }

    var result;
    var result2;

    switch(global.kOs){
      case "android" : {
        result = await compute(updateData_static, [dataManager.infoFromFiles]);
        dataForChart2 = result[0];
        medianCoordinate = result[1];
        numberOfImages = result[2];

        result2 = await compute(modifyData_static, [
          dataForChart2,
          medianCoordinate,
          physicalWidth,
          numberOfImages,
          sizeOfChart.width
        ]);}
      break;
      case "ios" :  {
        result = await updateData_static([dataManager.infoFromFiles]);
        dataForChart2 = result[0];
        medianCoordinate = result[1];
        numberOfImages = result[2];

        result2 = await modifyData_static([
          dataForChart2,
          medianCoordinate,
          physicalWidth,
          numberOfImages,
          sizeOfChart.width
        ]);
      }
    }

    dataForChart2_modified = result2[0];

    listOfYears = dataForChart2_modified.keys.toList();
    if(listOfYears.length > maxNumOfYearChart) {listOfYears = listOfYears.sublist(0, maxNumOfYearChart);}

    notifyListeners();
  }

  void getMedianCoordinate(List<Coordinate> coordinates) {
    if (coordinates.isEmpty) return;

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
    if (coordinates.isEmpty) return Coordinate(37.55, 127.0);

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

  static Future<List> modifyData_static(List input) async {
    print("static modify data of yearStateProvider");

    Map dataForChart2 = input[0];
    Coordinate? medianCoordinate = input[1];
    double physicalWidth = input[2];
    Map<int, int> numberOfImages = input[3];
    double sizeOfChart = input[4];
    Map dataForChart2_modified = {};
    if (dataForChart2 == {}) return [{}];

    //get proper reference of number of image
    int maximumNumberOfImagesInYear = numberOfImages.values.reduce(max);
    int indexOfMaximumNumberOfImages =
        numberOfImages.values.toList().indexOf(maximumNumberOfImagesInYear);
    numberOfImages.forEach((key, value) {
      print("$key, $value}");
    });
    int year = dataForChart2.keys.elementAt(indexOfMaximumNumberOfImages);
    var data = dataForChart2[year];
    print("max : $year");

    print(List<int>.generate(
        data.length, (index) => data.values.elementAt(index)[0].length));
    int maximumNumberOfImages = List<int>.generate(
            data.length, (index) => data.values.elementAt(index)[0].length)
        .reduce(max);
    print("max : ${maximumNumberOfImages}");

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

        yLocationExpanded = yLocationExpanded;

        double xLocationNotExpanded = positionNotExpanded[indexOfDate][0];
        double yLocationNotExpanded = positionNotExpanded[indexOfDate][1];

        xLocationNotExpanded = (1 - i * 0.1) * xLocationNotExpanded;
        yLocationNotExpanded = (1 - i * 0.1) * yLocationNotExpanded;
        yLocationNotExpanded = yLocationNotExpanded;

        int numberOfImages = data[date]?[0].length ?? 1;
        Coordinate? coordinate = data[date]!.length > 1
            ? data[date]![1]
            : Coordinate(
                medianCoordinate!.latitude, medianCoordinate.longitude);

        double diffInCoord =
            (coordinate!.longitude! - medianCoordinate!.longitude!).abs();

        diffInCoord = diffInCoord > 215 ? 215 : diffInCoord;

        int locationClassification = 4;
        if (diffInCoord < 3) locationClassification = 3;
        if (diffInCoord < 0.5) locationClassification = 2;
        if (diffInCoord < 0.1) locationClassification = 1;
        if (diffInCoord < 0.01) locationClassification = 0;

        double hue = hueList.elementAt(locationClassification);

        // Color color = (coordinate == null) | (coordinate.longitude == null)
        //     ? Colors.grey.withAlpha(100)
        //     : HSLColor.fromAHSL(0.5, hue, 67 / 100, 50 / 100).toColor();
        Color color =  (coordinate == null) | (coordinate.longitude == null)? Colors.grey.withAlpha(100): colorList2.elementAt(locationClassification);
        // double size = numberOfImages / 5.toDouble();
        double size = numberOfImages / maximumNumberOfImages * (maximumSizeOfScatter + 5);
        size = size < maximumSizeOfScatter ? size : maximumSizeOfScatter;
        size = size > minimumSizeOfScatter ? size : minimumSizeOfScatter;

        List entries = data[date]![0];

        double leftExpanded = xLocationExpanded * (physicalWidth) / 2 +
            sizeOfChart / 2 -
            size / 2;
        double topExpanded =
            yLocationExpanded * physicalWidth / 2 + sizeOfChart / 2 - size / 2;

        double leftNotExpanded = xLocationNotExpanded * (physicalWidth) / 2 +
            sizeOfChart / 2 -
            size / 2;
        double topNotExpanded = yLocationNotExpanded * physicalWidth / 2 +
            sizeOfChart / 2 -
            size / 2;

        double leftExpandedExtra = positionNotExpanded[indexOfDate][0] *
                (1.7 - 0.05 * i) *
                (physicalWidth) /
                2 +
            sizeOfChart / 2 -
            size / 2;

        double topExpandedExtra = positionNotExpanded[indexOfDate][1] *
                (1.7 - 0.05 * i) *
                physicalWidth /
                2 +
            sizeOfChart / 2 -
            size / 2;

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

    return [dataForChart2_modified];
  }


  void setHighlightedYear(int? year) {
    highlightedYear = year;
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
  void setExpandedYearByButton(){
    int last = listOfYears.last;
    if(expandedYear==null){
        setExpandedYear(listOfYears.elementAt(0));
        return;
      }
      if(expandedYear == listOfYears.last){
        setExpandedYear(listOfYears.first);
        return;}

      setExpandedYear(expandedYear!-1);

  }
  void setAngle(double angle){
    this.angle = angle;
    notifyListeners();
  }

  @override
  void dispose() {
    print("yearPageSTateProvider disposed");
  }
}
