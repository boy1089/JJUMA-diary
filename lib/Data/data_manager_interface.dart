import 'package:flutter/foundation.dart';
import 'package:jjuma.d/Location/coordinate.dart';
import 'package:jjuma.d/Data/info_from_file.dart';
import 'package:jjuma.d/Data/data_repository.dart';

import '../pages/event.dart';
import 'android_data_manager.dart';
import 'ios_data_manager.dart';

abstract class DataManagerInterface extends ChangeNotifier {
  factory DataManagerInterface(String type) {
    switch (type) {
      case "ios": return IosDataManager();
      case "android": return AndroidDataManager();
      default: return AndroidDataManager();
    }
  }
  void setNote(DateTime datetime, String note);
  void setFilenameOfFavoriteImage(DateTime datetime, String? indexOfFavoriteImage);

  Map<String, int> summaryOfPhotoData = {};
  Map<String, double> summaryOfLocationData = {};
  Map<String, Coordinate> summaryOfCoordinate = {};

  Map<String, Map<String, String>> noteForChart2 = {};
  Map<String, Map<String, String?>> filenameOfFavoriteImages = {};

  List setOfDates = [];
  List dates = [];
  List datetimes = [];
  List setOfDatetimes = [];
  List files = [];
  List? filesNotUpdated = [];
  Map<String, Event> eventList = {};
  List<String>? datesOutOfDate = [];

  Map<dynamic, InfoFromFile> infoFromFiles = {};

  DataRepository dataRepository = DataRepository();

  Future<void> init() async {}
  static Future<Map<dynamic, InfoFromFile>> updateDatesOnInfo_ios(
      List input) async {
    return {};
  }

  void executeSlowProcesses() async {}
  Future<List?> matchFilesAndInfo() async {}
  Future<void> addFilesToInfo(List? filenames) async {}
  Future<void> updateDateOnInfo(List? input) async {}
  Future<List<String>> resetInfoFromFiles() async {
    return [];
  }

  static Future<List> updateDatesFromInfo(List input) async {
    return [];
  }

  static Future<Map<dynamic, InfoFromFile>> updateExifOnInfo_compute(
      List input) async {
    return {};
  }

  static Future<Map<String, int>> updateSummaryOfPhotoFromInfo(
      List input) async {
    return {};
  }

  static Future<Map<String, double>>
      updateSummaryOfLocationDataFromInfo2_compute(List input) async {
    return {};
  }

  static Future<Map<String, double>>
      updateSummaryOfLocationDataFromInfo_compute(List input) async {
    return {};
  }

  void addEvent(Event event){
  }

  @override
  dispose(){
    print("DataManager disposed");
    super.dispose();
  }


}
