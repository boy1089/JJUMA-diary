import 'package:flutter/material.dart';
import 'package:lateDiary/Data/infoFromFile.dart';
import 'package:lateDiary/Location/Coordinate.dart';

class DataStateProvider with ChangeNotifier{
  List files = [];
  List setOfDates = [];
  List dates = [];
  List datetimes = [];
  List setOfDatetimes = [];
  List locations = [];
  Map<String, int> summaryOfPhotoData = {};
  Map<String, int> summaryOfNoteData = {};
  Map<String, double> summaryOfLocationData = {};
  Map<String, double> summaryOfDistanceData = {};

  Map<String, InfoFromFile> infoFromFiles = {};
  Coordinate referenceCoordinate = Coordinate(37.364, 126.718);


  void setFiles(List files){
    this.files = files;
    notifyListeners();
  }
  void setSetOfDates(List setOfDates){
    this.setOfDates = setOfDates;
    notifyListeners();
  }
  void setDates(List dates){
    this.dates = dates;
    notifyListeners();
  }
  void setDatetimes(List datetimes){
    this.datetimes = datetimes;
    notifyListeners();
  }

  void setSetOfDatetimes(List setOfDatetimes){
    this.setOfDatetimes = setOfDatetimes;
    notifyListeners();
  }
  void setLocations(List locations){
    this.locations = locations;
    notifyListeners();
  }
  void setSummaryOfPhotoData(Map<String, int> summaryOfPhotoData){
    this.summaryOfPhotoData = summaryOfPhotoData;
    notifyListeners();
  }
  void setSummaryOfNoteData(Map<String, int> summaryOfNoteData){
    this.summaryOfNoteData = summaryOfNoteData;
    notifyListeners();
  }
  void setSummaryOfLocationData(Map<String, double> summaryOfLocationData){
    this.summaryOfLocationData = summaryOfLocationData;
    notifyListeners();
  }
  void setSummaryOfDistanceData(Map<String, double> summaryOfDistanceData){
    this.summaryOfDistanceData = summaryOfDistanceData;
    notifyListeners();
  }
  void setInfoFromFiles(Map<String, InfoFromFile> infoFromFiles){
    this.infoFromFiles = infoFromFiles;
    notifyListeners();
  }


}