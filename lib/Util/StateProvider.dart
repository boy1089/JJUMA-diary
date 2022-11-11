import 'package:flutter/material.dart';
import 'package:test_location_2nd/Util/DateHandler.dart';

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

class UiStateProvider with ChangeNotifier {
  String date = formatDate(DateTime.now());
  Map summaryOfGooglePhotoData = {};
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

  @override
  void dispose() {
    print("provider disposed");
  }
}

class YearPageStateProvider with ChangeNotifier {
  String date = formatDate(DateTime.now());
  Map summaryOfGooglePhotoData = {};
  double zoomInAngle = 0.0;
  bool isZoomIn = false;
  bool isBottomNavigationBarShown = true;
  int lastNavigationIndex = 0;
  int year = DateTime.now().year;

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
  void setYear(year){
    print("provider set year to $year");
    this.year = year;
    notifyListeners();
  }

  @override
  void dispose() {
    print("provider disposed");
  }
}

class DayPageStateProvider with ChangeNotifier {
  String date = formatDate(DateTime.now());
  Map summaryOfGooglePhotoData = {};
  double zoomInAngle = 0.0;
  bool isZoomIn = false;
  bool isBottomNavigationBarShown = true;
  int lastNavigationIndex = 0;
  List<String> availableDates = [];

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

  void setAvailableDates(availableDates){
    print("provider set isZoomIn to $isZoomIn");
    this.availableDates = availableDates;
    notifyListeners();
  }

  @override
  void dispose() {
    print("provider disposed");
  }
}
