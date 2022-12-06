import 'package:flutter/material.dart';
import 'package:lateDiary/Util/DateHandler.dart';
import 'package:lateDiary/Util/Util.dart';
import 'dart:math';
import 'package:intl/intl.dart';

import '../Data/DataManagerInterface.dart';

class YearPageStateProvider with ChangeNotifier {
  String date = formatDate(DateTime.now());
  double zoomInAngle = 0.0;
  bool isZoomIn = false;
  bool isBottomNavigationBarShown = true;
  int lastNavigationIndex = 0;
  int year = DateTime.now().year;
  int index = 0;

  DataManagerInterface dataManager;
  YearPageStateProvider(this.dataManager) {
    update(dataManager);
  }

  dynamic data;
  List<dynamic> dataList = [];
  List<String> availableDates = [];
  int maxOfSummary = 0;

  void update(dataManager) {
    this.dataManager = dataManager;
    updateDataList();
    notifyListeners();
  }

  void setAvailableDates(int year) {
    availableDates = dataManager.summaryOfPhotoData.keys.where((element) {
      return element.substring(0, 4) == year.toString();
    }).toList();
    availableDates.sort();
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
    this.dataList = dataList;
    print("dataList : $dataList");
    print("dateList : $availableDateList");
    print("years : $years");
    notifyListeners();
  }

  dynamic modifyDataFormat(List<String> availableDates) {
    var dataTemp = List.generate(1, (index) {
      return [
        0,
        1,
        10,
        0.01,
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
      ];
    });
    return dataTemp;
  }

  void setBottomNavigationBarShown(bool isBottomNavigationBarShown) {
    this.isBottomNavigationBarShown = isBottomNavigationBarShown;
    print("isBottomNavigationBarShown : $isBottomNavigationBarShown");
    notifyListeners();
  }

  void setLastNavigationIndex(int index) {
    lastNavigationIndex = index;
  }

  void setDate(DateTime date) {
    this.date = formatDate(date);
    print("date : ${this.date}");
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

  void setIndex(int index) {
    this.index = index;
  }

  @override
  void dispose() {
    print("yearPageSTateProvider disposed");
  }
}
