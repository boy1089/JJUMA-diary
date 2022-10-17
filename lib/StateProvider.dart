
import 'package:flutter/material.dart';
import 'package:test_location_2nd/DateHandler.dart';

class NavigationIndexProvider with ChangeNotifier{
  int navigationIndex = 0;
  String date = formatDate(DateTime.now());

  void setNavigationIndex(int index){
    navigationIndex = index;
    print("index : $navigationIndex");
    notifyListeners();
  }
  void setDate(DateTime date){
    this.date = formatDate(date);
    print("date : ${this.date}");
  }
  // void set

}