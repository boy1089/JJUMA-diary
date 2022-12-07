import 'package:flutter/material.dart';
import 'package:lateDiary/Util/DateHandler.dart';
import 'package:lateDiary/Util/Util.dart';
import 'dart:math';
import 'package:intl/intl.dart';

import '../Data/data_manager_interface.dart';

class YearPageStateProvider with ChangeNotifier {
  int index = 0;
  double zoomInAngle = 0.0;
  bool isZoomIn = false;
  List<dynamic> dataForChartList = [];
  //TODO remove availableDates
  List<String> availableDates = [];


  DataManagerInterface dataManager;
  YearPageStateProvider(this.dataManager) {
    update(dataManager);
  }

  void update(dataManager) {
    this.dataManager = dataManager;
    updateDataList();
    notifyListeners();
  }


  void updateDataList() {
    List<int> years =
        List<int>.generate(20, (index) => DateTime.now().year - index);
    List<List<String>> availableDateList =
        List<List<String>>.generate(20, (index) {
      return dataManager.summaryOfPhotoData.keys
          .where(
              (element) => element.substring(0, 4) == years[index].toString())
          .toList();
    });
    List<dynamic> dataList = [];

    for (int i = 0; i < 20; i++) {
      dataList.add(modifyDataFormat(availableDateList.elementAt(i)));
    }
    this.dataForChartList = dataList;
    notifyListeners();
  }

  dynamic modifyDataFormat(List<String> availableDates) {
    var dataTemp = List.generate(1, (index) {
      return [
        0,
        1,
        10,
        0.01,
        0
      ];
    });

    if (availableDates.length == 0) return dataTemp;

    int weekdayOfJan01 = formatDateString(availableDates.elementAt(0)).weekday;
    int offsetToMakeWeekendOutward = -2;

    //generate data for graph plot
    dataTemp = List.generate(availableDates.length, (index) {
      String date = availableDates[index];
      int days = int.parse(DateFormat("D").format(DateTime.parse(date))) +
          weekdayOfJan01 +
          offsetToMakeWeekendOutward;
      int value = dataManager.summaryOfPhotoData[date]! > 200
          ? 200
          : dataManager.summaryOfPhotoData[date]!;
      double distance = 4;
      if (dataManager.summaryOfLocationData.containsKey(date))
        distance = floorDistance(dataManager.summaryOfLocationData[date]!);
      return [
        (days / 7).floor(),
        days % 7,
        value,
        distance,
        int.parse(date)
      ];
    });
    return dataTemp;
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
