import 'package:flutter/material.dart';
import 'package:lateDiary/Util/DateHandler.dart';
import 'package:lateDiary/Util/Util.dart';
import 'dart:math';
import 'package:intl/intl.dart';

import '../Data/data_manager_interface.dart';

enum ImportanceFilter { memorable, casual, none }
enum LocationFilter {  home,trip, none }


class YearPageStateProvider with ChangeNotifier {
  int index = 0;
  double zoomInAngle = 0.0;
  bool isZoomIn = false;
  List<dynamic> dataForChartList = [];
  //TODO remove availableDates
  List<String> availableDates = [];
  int importanceFilterIndex = ImportanceFilter.memorable.index;
  int locationFilterIndex = LocationFilter.trip.index;

  DataManagerInterface dataManager;
  YearPageStateProvider(this.dataManager) {
    update(dataManager);
  }

  void setImportanceFilter(int index) {
    importanceFilterIndex = index;
    updateDataList();
    notifyListeners();
  }

  void setLocationFilter(int index) {
    locationFilterIndex = index;
    updateDataList();
    notifyListeners();
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
      int distance = 0;
      switch (LocationFilter.values.elementAt(locationFilterIndex)) {
        case LocationFilter.home:
          distance = 5;
          break;
        case LocationFilter.trip:
          distance = 20;
          break;
        case LocationFilter.none:
          distance = 1000;
          break;
      }
      dataManager.summaryOfLocationData.forEach((key, value) {print("$key, $value}");});
      var test = Map.fromEntries(dataManager.summaryOfLocationData.entries
          .where((element) => element.value < distance));


      int minimumNumberOfImages = 0;
      switch (ImportanceFilter.values.elementAt(importanceFilterIndex)) {
        case ImportanceFilter.memorable:
          minimumNumberOfImages = 40;
          break;
        case ImportanceFilter.casual:
          minimumNumberOfImages = 20;
          break;
        case ImportanceFilter.none:
          minimumNumberOfImages = 0;
          break;
      }

      // var test = Map.fromEntries(dataManager.summaryOfPhotoData.entries
      //     .where((element) => element.value > minimumNumberOfImages));

      return test.keys
          .where(
              (element) => element.substring(0, 4) == years[index].toString())
          .toList();
    });

    List<dynamic> dataList = [];

    for (int i = 0; i < 20; i++) {
      dataList.add(modifyDataFormat(availableDateList.elementAt(i)));
    }
    // dataList = filterDataWithImportance(dataList);
    this.dataForChartList = dataList;
    notifyListeners();
  }

  // List<dynamic> filterDataWithImportance(List<dynamic> input) {
  //   print("filterWithImportance");
  //   List<dynamic> data = input[0];
  //
  //   for (int i = 0; i < data.length; i++) {
  //     print("$i, ${data[data.length - 1 - i]}");
  //     print(data);
  //     if (data[data.length - 1 - i][2] < minimumNumberOfImages)
  //       data.removeAt(data.length - 1 - i);
  //   }
  //   return [data];
  // }

  dynamic modifyDataFormat(List<String> availableDates) {
    var dataTemp = List.generate(1, (index) {
      return [0, 1, 10, 0.01, 0];
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
      return [(days / 7).floor(), days % 7, value, distance, int.parse(date)];
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
