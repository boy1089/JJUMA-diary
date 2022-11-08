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
  DataManager(this.photoDataManager, this.locationDataManager) {}

  Future<void> init() async {
    print("DataManager instance is initializing..");
    // var a = await readSummaryOfPhotoData();
    print("DataManager, updatingSummaryOfPhoto..");
    await updateSummaryOfPhoto();
    await updateSummaryOfLocationData();
    print("DataManager initialization done");
  }

  Future<void> updateSummaryOfPhoto() async {
    print("updateSummaryOfLocalPhoto..");
    List newList = photoDataManager.dates;
    Set ListOfDates = newList.toSet();
    final map = Map<String, int>.fromIterable(ListOfDates,
        key: (item) => item,
        value: (item) => newList.where((c) => c == item).length);
    summaryOfPhotoData = map;
    global.summaryOfPhotoData = summaryOfPhotoData;
    print("updateSummaryOfPhoto done, summary : ${summaryOfPhotoData}");
  }


  //updateSummaryOfLocationData is seperated from reading, updating location data
  //as the meaning of summary can get different
  Future<void> updateSummaryOfLocationData() async {
    print("updateSummaryOfCoordinate..");
    List listOfDates = global.dates;
    Set setOfDates = listOfDates.toSet();
    for (int i = 0; i < setOfDates.length; i++) {
      String date = setOfDates.elementAt(i);
      if (global.summaryOfLocationData.containsKey(date))
      try {
        print("updateSummaryOfLocation, date : $date");
        global.summaryOfLocationData[date] =
            locationDataManager.getMaxDistanceOfDate(date);
      } catch (e) {};
    }
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
