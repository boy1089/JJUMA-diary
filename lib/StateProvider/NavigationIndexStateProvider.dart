import 'package:flutter/material.dart';
import 'package:test_location_2nd/Util/DateHandler.dart';
import '../Util/global.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class NavigationIndexProvider with ChangeNotifier {
  int navigationIndex = 0;
  String date = formatDate(DateTime.now());
  double zoomInAngle = 0.0;
  bool isZoomIn = false;
  bool isBottomNavigationBarShown = true;
  int lastNavigationIndex = 0;

  void setBottomNavigationBarShown(bool isBottomNavigationBarShown) {
    this.isBottomNavigationBarShown = isBottomNavigationBarShown;
    print("isBottomNavigationBarShown : $isBottomNavigationBarShown");
    notifyListeners();
  }

  void setLastNavigationIndex(int index) {
    lastNavigationIndex = index;
  }

  void setNavigationIndex(int index) {
    setLastNavigationIndex(navigationIndex);
    navigationIndex = index;
    print("index : $navigationIndex");
    if (index == 0) {
      setBottomNavigationBarShown(true);
    }
    if (index == 1) {
      setBottomNavigationBarShown(true);
    }
    if (index == 2) {
      setBottomNavigationBarShown(false);
    }
    notifyListeners();
  }

  void setDate(DateTime date) {
    this.date = formatDate(date);
    print("date : ${this.date}");
  }
}
