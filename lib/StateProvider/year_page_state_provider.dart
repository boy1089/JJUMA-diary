import 'package:flutter/material.dart';
import 'package:lateDiary/Data/info_from_file.dart';
import 'package:lateDiary/Util/DateHandler.dart';
import 'package:lateDiary/Util/Util.dart';
import 'dart:math';
import 'package:intl/intl.dart';

import '../Data/data_manager_interface.dart';
import '../Location/coordinate.dart';

enum ImportanceFilter { memorable, casual, none }

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
  Map<int, Map<String, List>> dataForChart2 = {};
  int? expandedYear = null;
  Coordinate? averageCoordinate;

  DataManagerInterface dataManager;
  YearPageStateProvider(this.dataManager) {
    updateData();
  }
  void setExpandedYear(int? year) {
    expandedYear = year;
    notifyListeners();
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

    averageCoordinate = Coordinate(latitude/ coordinates.length, longitude/coordinates.length);

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

  @override
  void dispose() {
    print("yearPageSTateProvider disposed");
  }
}
