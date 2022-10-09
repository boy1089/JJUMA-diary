import 'package:path_provider/path_provider.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'dart:io';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:matrix2d/matrix2d.dart';
import 'package:flutter/foundation.dart';
import 'package:test_location_2nd/Util/Util.dart';

class DataReader {
  List<File> files2 = [];
  var data;
  List<List<List<dynamic>>> dataAll = [];
  List<String> dates = [];
  bool permissionGranted = false;
  String status = "";
  DataReader() {
    debugPrint('DataReader is reading Files');
    readFiles();
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

  Future<List<File>> getFiles() async {
    String? kRoot = await _localPath;
    _getStoragePermission();

    FileManager fm = FileManager(root: Directory('$kRoot/sensorData')); //
    Future<List<File>> files = fm.filesTree(
      extensions: [".csv"],
    );
    debugPrint("path : $kRoot/usageData");

    return files;
  }

  Future<List<List<List<dynamic>>>> readFiles() async {
    List<File> files = await getFiles();
    debugPrint("dataReader, readFiles : $files");
    dataAll = [];
    dates = [];
    files2 = files; //assigning files to class variable to later use.
    for (int i = 0; i < files.length; i++) {
      data = await openFile(files.elementAt(i).path);
      debugPrint('readFiles, $i th data');
      data = subsampleList(data, 10);
      String date = files[i].path.split('/').last.substring(0, 8);
      dates.add(date);
      dataAll.add(data);
    }
    debugPrint("DataReader, readFiles done");
    return dataAll;
  }

  List<dynamic> subsampleList(List list, int factor) {
    factor ??= 10;
    List<List<dynamic>> newList = [];
    for (int i = 0; i < list.length; i++) {
      if (i % factor == 0) newList.add(list[i]);
    }
    return newList;
  }

  Future<DataFrame> readFile(path) async {
    data = await fromCsv(path);
    return data;
  }

  Future<List> openFile(filepath) async {
    File f = File(filepath);
    debugPrint("CSV to List");
    final input = f.openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter(eol: '\n'))
        .toList();
    List list = convertStringTimeToInt(fields);
    return list;
  }
}
