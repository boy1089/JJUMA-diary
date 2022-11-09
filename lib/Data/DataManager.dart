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
    // await updateSummaryOfPhoto();
    // await updateSummaryOfLocationData();
    print("DataManager initialization done");
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

    files = files.where((element)=>!element.contains('thumbnail')).toList();

    global.infoFromFiles = {};
    global.infoFromFiles.addAll(Map.fromIterable(files, key: (v) => v, value: (v) => InfoFromFile()));

    return files;
  }

  Future<void> updateDateOnInfo() async {
    var data = global.infoFromFiles;
    for(int i = 0; i< data.length; i++){
      String key =data.keys.elementAt(i);
      String? inferredDatetime = inferDatetimeFromFilename(key);
      if(inferredDatetime !=null)
      {
        print(inferredDatetime);
        data[key]?.datetime =
            DateTime.parse(inferredDatetime!);
        data[key]?.date = inferredDatetime?.substring(0, 8);
      }
      print("updateDateOnInfo : $i / ${data.length}, ${data[key].toString()}");
    }
  }

  Future<void> updateExifOnInfo() async {
    var data = global.infoFromFiles;
    for(int i = 0; i< data.length; i++) {
      String key =data.keys.elementAt(i);
      List ExifData = await getExifInfoOfFile(key);
      data[key]?.coordinate = ExifData[1];
      if(ExifData[0] != "null") {
        data[key]?.datetime = DateTime.parse(ExifData[0]);
        data[key]?.date = ExifData[0].substring(0, 8);
      }
      print("updateExifOninfo : $i / ${data.length}, ${data[key].toString()}");
    }
    }

  Future<void> writeInfo() async {
    final Directory? directory = await getExternalStorageDirectory();
    final File file = File('${directory?.path}/InfoOfFiles.csv');
    if(!await file.exists())
      await file.writeAsString('filename,datetime,date,latitude,longitude,distance\n',
          mode: FileMode.write);
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
      if(i%100 ==0)
        print("writingInfo.. $i/${data.length}");

    }
  }
  Future<void> readInfo() async {
    final Directory? directory = await getExternalStorageDirectory();
    final File file = File('${directory?.path}/InfoOfFiles.csv');
    var data = await openFile(file.path);
    for (int i = 1; i < data.length; i++) {
      if (data[i].length <2) return;

      InfoFromFile infoFromFile = InfoFromFile();
      infoFromFile.datetime= parseToDatetime(data[i][1]);
      infoFromFile.date = parseToString(data[i][2]);
      infoFromFile.coordinate = Coordinate(parseToDouble(data[i][3]),parseToDouble(data[i][4]));
      infoFromFile.distance = data[i][5]=="null"? null:double.parse(data[i][5]);
      global.infoFromFiles[data[i][0]]= infoFromFile;

      if(i%100==0)
        print("readInfo.. $i / ${data.length}");

}
  }
  DateTime? parseToDatetime(input){
    if(input == null)
      return null;
    if(input.runtimeType== String)
      {
        try {
          return DateTime.parse(input);
        } catch(e) {
          print("error in parseToDatetime, invalid format? $e");
          return null;
        }
      }
    return input;
  }


  String? parseToString(input){
    if(input == "null")
      return null;
    if(input == null)
      return null;
    return input.toString();
  }


  double? parseToDouble(input){
    if(input == "null")
      return null;
    if(input == null)
      return null;
    if(input.runtimeType=="String")
      double.parse(input);
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
    print("updateSummaryOfLocationData..");
    List listOfDates = global.dates;
    Set setOfDates = listOfDates.toSet();
    for (int i = 0; i < setOfDates.length; i++) {
      String date = setOfDates.elementAt(i);
      if (global.summaryOfLocationData.containsKey(date))
      try {
        print("updateSummaryOfLocation, date : $date, ${locationDataManager.getMaxDistanceOfDate(date)}");
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
