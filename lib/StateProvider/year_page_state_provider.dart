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

  DataManagerInterface dataManager;
  YearPageStateProvider(this.dataManager) {
    updateData();
  }

  void updateData() {
    List<int> listOfYears =
        List<int>.generate(10, (index) => DateTime.now().year - index);
    for (int year in listOfYears) {
      Map<String, InfoFromFile> data =Map.from(dataManager.infoFromFiles)
        ..removeWhere((k, v) => v.datetime?.year != year);
      if(data.isNotEmpty)
       listOfImagesInYears[year.toString()] = data;
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
