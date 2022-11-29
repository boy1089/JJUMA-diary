import 'package:flutter/material.dart';
import 'package:lateDiary/Util/DateHandler.dart';

class NavigationIndexProvider with ChangeNotifier {
  navigationIndex currentNavigationIndex = navigationIndex.year;
  String date = formatDate(DateTime.now());
  double zoomInAngle = 0.0;
  bool isZoomIn = false;
  bool isBottomNavigationBarShown = true;
  navigationIndex lastNavigationIndex = navigationIndex.year;

  void setBottomNavigationBarShown(bool isBottomNavigationBarShown) {
    this.isBottomNavigationBarShown = isBottomNavigationBarShown;
    print("isBottomNavigationBarShown : $isBottomNavigationBarShown");
    notifyListeners();
  }

  void setLastNavigationIndex(navigationIndex index) {
    lastNavigationIndex = index;
  }

  void setNavigationIndex(navigationIndex index) {
    setLastNavigationIndex(currentNavigationIndex);
    currentNavigationIndex = index;
    print("index : $currentNavigationIndex");

    notifyListeners();

    if (index == navigationIndex.year) {
      setBottomNavigationBarShown(true);
    }
    if (index == navigationIndex.diary) {
      setBottomNavigationBarShown(true);
    }
    if (index == navigationIndex.day) {
      setBottomNavigationBarShown(false);
    }

    if (index == navigationIndex.setting) {
      setBottomNavigationBarShown(true);
    }
  }

  void setDate(DateTime date, {bool notify : false}) {
    this.date = formatDate(date);
    print("date : ${this.date}, 1111");
    if(notify)
      notifyListeners();
  }
}

enum navigationIndex{
  year,diary, day,  setting
}