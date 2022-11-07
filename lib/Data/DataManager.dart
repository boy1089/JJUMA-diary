import 'dart:io';
import 'package:glob/list_local_fs.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:glob/glob.dart';
import 'package:test_location_2nd/Util/global.dart' as global;
import 'package:test_location_2nd/Photo/PhotoDataManager.dart';
import 'package:test_location_2nd/Location/AddressFinder.dart';
import 'package:test_location_2nd/Location/LocationDataManager.dart';
import "package:test_location_2nd/Location/Coordinate.dart";

class DataManager {
  Map<String, int> summaryOfPhotoData = {};
  Map<String, Coordinate> summaryOfCoordinate = {};
  PhotoDataManager photoDataManager;
  LocationDataManager locationDataManager;

  DataManager(this.photoDataManager, this.locationDataManager) {
    print("DataManager instance in under creation");
    // init();
    print("DataManager instance is created");
  }

  Future<void> init() async {
    print("DataManager instance is initializing..");
    // var a = await readSummaryOfPhotoData();
    print("DataManager, updatingSummaryOfPhoto..");
    var a = await updateSummaryOfPhoto();
    print("DataManager, updatingSummaryOfCoordinate..");
    // while (global.isLocationUpadating) {
    //   await Future.delayed(Duration(seconds: 5));
    //   print("updating summaryOfLocation...");
    //   updateSummaryOfCoordinate();
    // };
    print("DataManager, updatingSummaryOfPhoto.. done");
  }

  Future<void> updateSummaryOfPhoto() async {
    print("updateSummaryOfLocalPhoto..");
    List newList = photoDataManager.dates;
    Set ListOfDates = newList.toSet();
    print("updateSummaryOfLocalPhoto2 ListOfDates $ListOfDates");
    final map = Map<String, int>.fromIterable(ListOfDates,
        key: (item) => item,
        value: (item) => newList.where((c) => c == item).length);
    summaryOfPhotoData = map;
    global.summaryOfPhotoData = summaryOfPhotoData;
    print("udpatesSummaryOfPhtoo data done, summary : ${summaryOfPhotoData}");
  }

  void updateSummaryOfCoordinate() async {
    print("updateSummaryOfCoordinate..");
    List listOfDates = global.dates;
    Set setOfDates = listOfDates.toSet();
    print("updateSummaryOfCoordinate ListOfDates $setOfDates");
    // final map = Map<String, List>.fromIterable(setOfDates,
    //     key: (item) => item,
    //     value: (item) => locationDataManager.getCoordinatesOfDate(item));
    // final map = Map<String, Coordinate?>.fromIterable(setOfDates,
    //     key: (item) => item,
    //     value: (item) => locationDataManager.getCoordinatesOfDate(item).first);

    // final map = Map<String, double>.fromIterable(setOfDates,
    //     key: (item) => item,
    //     value: (item) => locationDataManager.getMaxDistanceOfDate(item));
    //
    Map<String, double> map = {};
    for (int i = 0; i < setOfDates.length; i++) {
      String date = setOfDates.elementAt(i);
      try {
        map[date] = locationDataManager.getMaxDistanceOfDate(date);
      } catch (e) {};

    }
    print("updateSummaryOfCoordinate : $map");
    global.summaryOfLocationData = map;
  }

  Future<List> openFile(filePath) async {
    File f = File(filePath);
    debugPrint("CSV to List");
    final input = f.openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter(eol: '\n'))
        .toList();
    // print(slice(fields, [0, fields.shape[0]], [1]));
    return fields;
  }

  Future readSummaryOfPhotoData() async {
    final Directory? directory = await getExternalStorageDirectory();
    try {
      final fileName = Glob('${directory?.path}/summary_googlePhoto.csv')
          .listSync()
          .elementAt(0);
      print("readSummaryOfGooglePhotoData ${fileName.path}");
      var data = await openFile(fileName.path);
      for (int i = 0; i < data.length; i++) {
        if (data[i].length > 1) {
          summaryOfPhotoData[data[i][0].toString()] = await data[i][1];
        }
      }
      global.summaryOfPhotoData = summaryOfPhotoData;
      print("readSummary done");
      return summaryOfPhotoData;
    } catch (e) {
      print("error during readSummaryOfPhotoData : $e");
      return summaryOfPhotoData;
    }
  }
}
