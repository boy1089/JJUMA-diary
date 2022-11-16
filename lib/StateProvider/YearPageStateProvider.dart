import 'package:flutter/material.dart';
import 'package:test_location_2nd/Util/DateHandler.dart';
import '../Util/global.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class YearPageStateProvider with ChangeNotifier {
  String date = formatDate(DateTime.now());
  Map summaryOfGooglePhotoData = {};
  double zoomInAngle = 0.0;
  bool isZoomIn = false;
  bool isBottomNavigationBarShown = true;
  int lastNavigationIndex = 0;
  int year = DateTime.now().year;
  int index = 0;

  dynamic data;
  List<String> availableDates = [];
  int maxOfSummary = 0;

  void setAvailableDates(int year ){
    availableDates = summaryOfPhotoData.keys.where((element) {
      return element.substring(0, 4) == year.toString();
    }).toList();
    availableDates.sort();
  }

  void updateData() {
    setAvailableDates(year);

    data = List.generate(52, (index) {
      return [
        index,
        1,
        10,
        0.01,
      ];
    });
    if (availableDates.length == 0) return data;

    data = List.generate(availableDates.length, (index) {
      String date = availableDates[index];
      int days = int.parse(DateFormat("D").format(DateTime.parse(date)));
      int value =
          summaryOfPhotoData[date]! > 200 ? 200 : summaryOfPhotoData[date]!;

      double distance = 0.01;
      if (summaryOfLocationData[date] == null ||
          summaryOfLocationData[date] == 0) {
        distance = 0.01;
      } else {
        distance =
             floorDistance(summaryOfLocationData[date]!);
      }
      return [
        // days / 7.floor() + index % 3 / 4,
        // (days - 2) % 7,

        (days / 7).floor(),
        days % 7,

        value,
        distance,
      ];
    });
    List<int> dummy3 = List<int>.generate(transpose(data)[0].length,
        (index) => int.parse(transpose(data)[2][index].toString()));
    maxOfSummary = dummy3.reduce(max);
    print("year page, dummy3 : $maxOfSummary");

    // notifyListeners();
  }

  double floorDistance(double distance){
    if (distance>50)
      return 0;
    if(distance > 20)
      return 1;
    if(distance> 5)
      return 2;
    if(distance>1)
      return 3;
    return 4;
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

  void setSummaryOfGooglePhotoData(data) {
    summaryOfGooglePhotoData = data;
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

  void setYear(int year, {bool notify: false}) {
    print("provider set year to $year");
    this.year = year;
    setIndex(DateTime.now().year - year);
    updateData();

    if (notify) notifyListeners();
  }

  void setIndex(int index) {
    this.index = index;
  }

  @override
  void dispose() {
    print("provider disposed");
  }
}
