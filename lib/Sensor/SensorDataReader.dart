import 'package:glob/list_local_fs.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:lateDiary/Util/Util.dart';
import 'package:csv/csv.dart';
import 'package:glob/glob.dart';

//Reads one *_sensor.csv and put in dataAll variable.
class SensorDataReader {
  List<File> files2 = [];
  List<dynamic> dailyData = [];
  List<List<dynamic>> dailyDataAll = [];
  List<List<dynamic>> processedData = [];

  List<String> dates = [];
  bool permissionGranted = false;
  String status = "";

  SensorDataReader() {
    debugPrint('DataReader is reading Files');
    // readFiles();
  }

  Future<String?> get _localPath async {
    final directory2 = await getExternalStorageDirectories();
    var path = directory2?[0].path;
    return path;
  }

  Future _getStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      permissionGranted = true;
    } else if (await Permission.storage.request().isPermanentlyDenied) {
      await openAppSettings();
    } else if (await Permission.storage.request().isDenied) {
      permissionGranted = false;
    }
  }


  Future<List<FileSystemEntity>> getFiles() async {
    String? kRoot = await _localPath;
    _getStoragePermission();
    final files =  Glob("$kRoot/processedSensorData/*").listSync();

    return files;
  }

  Future<List<List<dynamic>>> readFiles() async {
    List<FileSystemEntity> files = await getFiles();
    debugPrint("dataReader, readFiles : $files");
    dailyDataAll = [];
    dates = [];
    for (int i = 0; i < files.length; i++) {
      dailyData = await openFile(files.elementAt(i).path);
      debugPrint('readFiles, $i th data');
      dailyData = subsampleList(dailyData, kDataReaderSubsampleFactor);
      String date = files[i].path.split('/').last.substring(0, 8);
      dates.add(date);
      dailyDataAll.add(dailyData);
    }
    debugPrint("DataReader, readFiles done");
    print(dailyDataAll);
    return dailyDataAll;

  }

  List<List<dynamic>> subsampleList(List list, int factor) {
    List<List<dynamic>> newList = [];
    for (int i = 0; i < list.length; i++) {
      if (i % factor == 0) newList.add(list[i]);
    }
    return newList;
  }

  Future<List> openFile(filepath) async {
    File f = File(filepath);
    final input = f.openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter(eol: '\n'))
        .toList();
    // List list = modifySensorDataForPlot(fields);
    List list = modifyListForPlot(fields);
    // List list = convertStringTimeToInt(fields);

    return list;
  }
}
