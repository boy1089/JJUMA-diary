import 'dart:io';
import 'package:glob/list_local_fs.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:glob/glob.dart';
import 'package:test_location_2nd/Util/DateHandler.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:test_location_2nd/Util/global.dart' as global;
import 'package:test_location_2nd/Photo/PhotoDataManager.dart';
import 'package:test_location_2nd/Location/AddressFinder.dart';
import 'package:test_location_2nd/Location/LocationDataManager.dart';
import "package:test_location_2nd/Location/Coordinate.dart";
import 'infoFromFile.dart';

List<String> pathsToPhoto = [
  "/storage/emulated/0/DCIM",
  "/storage/emulated/0/DCIM/Camera",
  "/storage/emulated/0/Pictures",
  "/storage/emulated/0/Pictures/*",
];

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
    await readInfo();
    await updateDatesFromInfo();
    await updateSummaryOfPhotoFromInfo();
    await updateSummaryOfLocationDataFromInfo();
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

  Future<void> updateDatesFromInfo() async {
    List dates = List.generate(global.infoFromFiles.length, (i) {
      var key = global.infoFromFiles.keys.elementAt(i);
      return global.infoFromFiles[key]?.date;
    });
    dates.removeWhere((i)=>i==null);
    global.dates = dates;
  }

  Future<void> updateSummaryOfPhotoFromInfo() async {
    List dates = global.dates;
    dates.removeWhere((i)=>i==null);
    final map = Map<String, int>.fromIterable(dates.toSet(),
        key: (item) => item,
        value: (item) {
          return dates.where((c) => c == item).length;
        });
    summaryOfPhotoData = map;
    global.summaryOfPhotoData = summaryOfPhotoData;
    print("updateSummaryOfPhoto done, summary : ${summaryOfPhotoData}");
  }

  Future<void> updateSummaryOfLocationDataFromInfo() async {
    print("updateSummaryOfLocationData..");
    List listOfDates = global.dates;
    Set setOfDates = listOfDates.toSet();
    for (int i = 0; i < setOfDates.length; i++) {
      String date = setOfDates.elementAt(i);
      global.summaryOfLocationData[date] =
          locationDataManager.getMaxDistanceOfDate(date);
    }
  }

  Future<List<String>> resetInfoFromFiles() async {
    List<String> files = [];
    List newFiles = [];
    for (int i = 0; i < pathsToPhoto.length; i++) {
      String path = pathsToPhoto.elementAt(i);

      newFiles = await Glob("$path/*.jpg").listSync();
      files.addAll(List.generate(
          newFiles.length, (index) => newFiles.elementAt(index).path));

      newFiles = await Glob("$path/*.png").listSync();
      files.addAll(List.generate(
          newFiles.length, (index) => newFiles.elementAt(index).path));
    }

    files = files.where((element) => !element.contains('thumbnail')).toList();

    global.infoFromFiles = {};
    global.infoFromFiles.addAll(
        Map.fromIterable(files, key: (v) => v, value: (v) => InfoFromFile()));

    return files;
  }

  Future<void> updateDateOnInfo() async {
    var data = global.infoFromFiles;
    for (int i = 0; i < data.length; i++) {
      String key = data.keys.elementAt(i);
      String? inferredDatetime = inferDatetimeFromFilename(key);
      if (inferredDatetime != null) {
        print(inferredDatetime);
        data[key]?.datetime = DateTime.parse(inferredDatetime!);
        data[key]?.date = inferredDatetime?.substring(0, 8);
      }
      print("updateDateOnInfo : $i / ${data.length}, ${data[key].toString()}");
    }
  }

  Future<void> updateExifOnInfo() async {
    var data = global.infoFromFiles;
    for (int i = 0; i < data.length; i++) {
      // for (int i = 10000; i < 11000; i++) {

        String key = data.keys.elementAt(i);
      List ExifData = await getExifInfoOfFile(key);
      data[key]?.coordinate = ExifData[1];
      if (ExifData[0] != "null") {
        data[key]?.datetime = DateTime.parse(ExifData[0]);
        data[key]?.date = ExifData[0].substring(0, 8);
      }
      if (ExifData[1] != null){
        data[key]?.distance = calculateDistanceToRef(ExifData[1]);
      }
      print("updateExifOninfo : $i / ${data.length}, ${data[key].toString()}");
    }
  }

  Future<void> writeInfo(bool overwrite) async {
    if(overwrite==null)
      overwrite = false;
    final Directory? directory = await getExternalStorageDirectory();
    final File file = File('${directory?.path}/InfoOfFiles.csv');

    if (!((await file.exists())) || overwrite) {
      print("overwritting");
      await file.writeAsString(
          'filename,datetime,date,latitude,longitude,distance\n',
          mode: FileMode.write);
    }
    var data = global.infoFromFiles;
    for (int i = 0; i < data.length; i++) {
      String key = data.keys.elementAt(i);

      await file.writeAsString(
          '${key},'
          '${data[key]!.datetime},'
          '${data[key]!.date},'
          '${data[key]!.coordinate?.latitude},'
          '${data[key]!.coordinate?.longitude},'
          '${data[key]!.distance}\n',
          mode: FileMode.append);
      if (i % 100 == 0) print("writingInfo.. $i/${data.length}");
    }
  }

  Future<void> readInfo() async {
    final Directory? directory = await getExternalStorageDirectory();
    final File file = File('${directory?.path}/InfoOfFiles.csv');
    var data = await openFile(file.path);
    for (int i = 1; i < data.length; i++) {
      if (data[i].length < 2) return;

      print("readInfo.. $i / ${data.length}, ${data[i]}");
      InfoFromFile infoFromFile = InfoFromFile();
      infoFromFile.datetime = parseToDatetime(data[i][1]);
      infoFromFile.date = parseToString(data[i][2]);
      infoFromFile.coordinate =
          Coordinate(parseToDouble(data[i][3]), parseToDouble(data[i][4]));
      infoFromFile.distance =
          data[i][5] == "null" ? null : parseToDouble(data[i][5]);
      global.infoFromFiles[data[i][0]] = infoFromFile;

      // if (i % 100 == 0)
    }
  }

  DateTime? parseToDatetime(input) {
    if (input == null) return null;
    if (input.runtimeType == String) {
      try {
        return DateTime.parse(input);
      } catch (e) {
        print("error in parseToDatetime, invalid format? $e");
        return null;
      }
    }
    return input;
  }

  String? parseToString(input) {
    if (input == "null") return null;
    if (input == null) return null;
    return input.toString();
  }

  double? parseToDouble(input) {
    if (input == "null") return null;
    if (input == null) return null;
    if (input.runtimeType == "String") double.parse(input);
    return input;
  }
}
