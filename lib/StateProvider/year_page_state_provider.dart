import 'package:flutter/material.dart';
import 'package:lateDiary/Util/DateHandler.dart';
import 'package:lateDiary/Util/Util.dart';
import 'dart:math';
import 'package:intl/intl.dart';

import '../Data/data_manager_interface.dart';

enum ImportanceFilter { memorable, casual, none }
enum LocationFilter { trip, none,  home,  }

int yearRange = 20;

class YearPageStateProvider with ChangeNotifier {
  int index = 0;
  double zoomInAngle = 0.0;
  bool isZoomIn = false;
  List<dynamic> dataForChartList = [];
  //TODO remove availableDates
  List<String> availableDates = [];
  int importanceFilterIndex = ImportanceFilter.none.index;
  int locationFilterIndex = LocationFilter.none.index;

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
        List<int>.generate(yearRange, (index) => DateTime.now().year - index);

    List<List<String>> availableDateList =
        List<List<String>>.generate(yearRange, (index) {
      List<int> distanceFilter = [0, 10];
      switch (LocationFilter.values.elementAt(locationFilterIndex)) {
        case LocationFilter.home:
          distanceFilter = [0, 5];
          break;
        case LocationFilter.trip:
          distanceFilter = [5, 100];
          break;
        case LocationFilter.none:
          distanceFilter = [0, 1000];
          break;
      }
      // dataManager.summaryOfLocationData.forEach((key, value) {print("$key, $value}");});
      var test = Map.fromEntries(dataManager.summaryOfLocationData.entries
          .where((element) => ((element.value < distanceFilter[1]) &&
              (element.value > distanceFilter[0]))));

      int minimumNumberOfImages = 0;
      switch (ImportanceFilter.values.elementAt(importanceFilterIndex)) {
        case ImportanceFilter.memorable:
          minimumNumberOfImages = 50;
          break;
        case ImportanceFilter.casual:
          minimumNumberOfImages = 10;
          break;
        case ImportanceFilter.none:
          minimumNumberOfImages = 0;
          break;
      }

      var test2 = Map.fromEntries(test.entries.where((element) =>
          dataManager.summaryOfPhotoData[element.key]! >
          minimumNumberOfImages));

      return test2.keys
          .where(
              (element) => element.substring(0, 4) == years[index].toString())
          .toList();
    });

    List<dynamic> dataList = [];

    for (int i = 0; i < yearRange; i++) {
      dataList.add(modifyDataFormat(availableDateList.elementAt(i)));
    }

    print(availableDateList);
    dataList[0].forEach((element) {
      print("$element");
    });

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

  List<List<dynamic>> modifyDataFormat(List<String> availableDates) {
    var dataTemp = List.generate(5, (index) {
      return [0, 1, index, 0.01, 0];
    });

    if (availableDates.length == 0) return dataTemp;

    int weekdayOfJan01 = DateTime(int.parse(availableDates.elementAt(0).substring(0, 4))).weekday;
    print("weekday : ${DateTime(int.parse(availableDates.elementAt(0).substring(0, 4)))}");
    int offsetToMakeWeekendOutward = -2;

    //generate data for graph plot
    dataTemp = List.generate(availableDates.length, (index) {
      String date = availableDates[index];
      int days = int.parse(DateFormat("D").format(DateTime.parse(date))) +
          weekdayOfJan01 +
          offsetToMakeWeekendOutward;
      print("$days, $date, $weekdayOfJan01, ${availableDates.elementAt(0).substring(4)}");
      int value = dataManager.summaryOfPhotoData[date]! > 200
          ? 200
          : dataManager.summaryOfPhotoData[date]!;
      double distance = 4;
      value = floorNumberOfImages(value);
      // if (dataManager.summaryOfLocationData.containsKey(date)) {
      distance = floorDistance(dataManager.summaryOfLocationData[date]!);
      // }
      return [(days / 7).floor(), days % 7, value, distance, int.parse(date)];
    });
    // dataTemp.addAll(List.generate(52, (index)=> [index, 7, 3, 0, 0]));
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
