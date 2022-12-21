import 'package:flutter/material.dart';
import 'package:lateDiary/Data/info_from_file.dart';
import 'package:lateDiary/Util/DateHandler.dart';
import 'package:lateDiary/Util/Util.dart';
import 'dart:math';
import 'package:intl/intl.dart';

import '../Data/data_manager_interface.dart';
import '../Location/coordinate.dart';
import '../pages/YearPage/year_page_screen2.dart';

enum ImportanceFilter { memorable, casual, none }

List positionExpanded = List.generate(366, (index) {
  double day = index.toDouble();
  double week = day / 7.ceil();
  double weekday = day % 7;
  double radius = (weekday + 3) / 11 * 1.2;
  double angle = week / 52 * 2 * pi;

  double xLocation = radius * cos(angle - pi / 2);
  double yLocation = radius * sin(angle - pi / 2);
  return [xLocation, yLocation];
});

List positionNotExpanded = List.generate(366, (index) {
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
  Coordinate? averageCoordinate;
  double? photoViewScale = 1;

  DataManagerInterface dataManager;
  YearPageStateProvider(this.dataManager) {
    updateData();
    modifyData();
  }


  void updateData() {
    dataForChart = [];
    dataForChart2 = {};
    List<Coordinate> coordinates = [];

    for (MapEntry entry in dataManager.infoFromFiles.entries) {
      DateTime datetime = entry.value.datetime;
      Coordinate? coordinate = entry.value.coordinate;
      int year = datetime.year;

      if (dataForChart2[year] == null) dataForChart2[year] = {};

      if (dataForChart2[year]![formatDate(datetime)] == null)
        dataForChart2[year]![formatDate(datetime)] = [[]];

      dataForChart2[year]![formatDate(datetime)]![0].add(entry);

      if(coordinate == null) continue;

      if(dataForChart2[year]![formatDate(datetime)]!.length ==2) {
        dataForChart2[year]![formatDate(datetime)]![1] = coordinate;
        continue;
      }
      dataForChart2[year]![formatDate(datetime)]!.add(coordinate);
      coordinates.add(coordinate);
    }
    double latitude = 0.0;
    double longitude = 0.0;
    for(Coordinate? coordinate in coordinates){
      latitude += coordinate?.latitude?? 0;
      longitude += coordinate?.longitude?? 0;
    }
    dataForChart2= Map.fromEntries(dataForChart2.entries.toList()..sort((e1, e2)=>e2.key.compareTo(e1.key)));

    averageCoordinate = Coordinate(latitude/ coordinates.length, longitude/coordinates.length);
    notifyListeners();
  }

  void modifyData(){
    for(int i = 0; i< dataForChart2.length; i++){
      int year = dataForChart2.keys.elementAt(i);
      var data = dataForChart2[year];
     dataForChart2_modified[year] = List.generate(data!.length, (index){
        String date = data.keys.elementAt(index);
        DateTime datetime = DateTime(year, int.parse(date.substring(4, 6)),
            int.parse(date.substring(6, 8)));
        int indexOfDate = datetime.difference(DateTime(year)).inDays;

        double xLocationExpanded =  positionExpanded[indexOfDate][0];
        double yLocationExpanded = positionExpanded[indexOfDate][1];

        xLocationExpanded = (1.0) * xLocationExpanded;
        yLocationExpanded = (1.0) * yLocationExpanded;

        yLocationExpanded = yLocationExpanded + 0.95;

        double xLocationNotExpanded =  positionNotExpanded[indexOfDate][0];
        double yLocationNotExpanded = positionNotExpanded[indexOfDate][1];

        xLocationNotExpanded = (1-i*0.1) * xLocationNotExpanded;
        yLocationNotExpanded = (1-i*0.1) * yLocationNotExpanded;
        yLocationNotExpanded = yLocationNotExpanded + 0.95;

        int numberOfImages = data[date]?[0].length ?? 1;
        Coordinate? coordinate = data[date]?[1];
        Color color = coordinate == null
            ? Colors.grey.withAlpha(150)
            : Color.fromARGB(
          100,
          // 0,
          255 -
              ((coordinate.longitude ??
                  127 - averageCoordinate!.longitude!) *
                  200)
                  .toInt(),
          150,
          ((coordinate.longitude ??
              127 - averageCoordinate!.longitude!)
              .abs() *
              200)
              .toInt(),
        );
        double size = 20;
        size = log(numberOfImages) * 5;
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

        double leftExpandedExtra = positionNotExpanded[indexOfDate][0]*1.5 * (physicalWidth) / 2 +
            (sizeOfChart.width) / 2 -
            size / 2;
        double topExpandedExtra = (positionNotExpanded[indexOfDate][1]*1.5 + 0.95) * physicalWidth / 2 +
            physicalWidth / 2 -
            size / 2;
        // return [xLocation, yLocation, size, color, entries];
        return [leftExpanded, topExpanded, leftNotExpanded, topNotExpanded, leftExpandedExtra, topExpandedExtra, size, color, entries, date];
      });

    }
    dataForChart2_modified = Map.fromEntries(dataForChart2_modified.entries.toList()..sort((e1, e2)=>e2.key.compareTo(e1.key)));
    notifyListeners();
  }

  void setPhotoViewScale(double photoViewScale){
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
