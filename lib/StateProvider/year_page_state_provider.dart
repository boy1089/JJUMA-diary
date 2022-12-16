import 'package:flutter/material.dart';
import 'package:lateDiary/Data/info_from_file.dart';
import 'package:lateDiary/Util/DateHandler.dart';
import 'package:lateDiary/Util/Util.dart';
import 'dart:math';
import 'package:intl/intl.dart';

import '../Data/data_manager_interface.dart';

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

  Map<String, Map<String, InfoFromFile>> listOfImagesInYears = {};
  Map<String, Map<String, InfoFromFile>> listOfImagesInMonths = {};

  List<List<dynamic>> dataForChart = [];

  DataManagerInterface dataManager;
  YearPageStateProvider(this.dataManager) {
    updateData();
  }

  void updateData() {
    dataForChart = [];
    List<int> listOfYears =
        List<int>.generate(10, (index) => DateTime.now().year - index);
    for (int year in listOfYears) {
      for(int day = 0; day < 365; day ++){
        if(day %100 ==0) print(year);
        DateTime currentDay = DateTime(year).add(Duration(days:day));
        int numberOfImages = dataManager.summaryOfPhotoData[formatDate(currentDay)]?? 0;
        // print(numberOfImages);
        Map<dynamic, InfoFromFile> images = Map.from(dataManager.infoFromFiles)..removeWhere((k, v) => v.datetime == currentDay);
        dataForChart.add([year, day/7.ceil(), currentDay.weekday, day, numberOfImages.toDouble(), images]);
      }
    }
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
