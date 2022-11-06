import 'dart:io';
import 'package:glob/list_local_fs.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:glob/glob.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:test_location_2nd/Util/global.dart' as global;
import 'package:test_location_2nd/Photo/GooglePhotoDataManager.dart';
import 'package:test_location_2nd/Util/DateHandler.dart';
import 'package:intl/intl.dart';
import 'package:test_location_2nd/Photo/LocalPhotoDataManager.dart';

class DataManager {
  var sensorDataAll;

  List<String> fileList = [];
  List<dynamic> processedSensorData = [];
  Map<String, int> summaryOfPhotoData = {};
  bool isUpdateInProgress = false;
  String processedFileName = "sensor_processed.csv";
  int updateIndexOfPhotoSummary = 0;
  LocalPhotoDataManager localPhotoDataManager;

  DataManager(this.localPhotoDataManager) {
    print("DataManager instance in under creation");
    // init();
    print("DataManager instance is created");
  }

  Future<void> init() async {
    print("DataManager instance is initializing..");
    // summaryOfPhotoData = await readSummaryOfPhotoData();
    var a = await readSummaryOfPhotoData();
    // await updateSummaryFromLocal("20220101", formatDate(DateTime.now()));
    await updateSummaryOfLocalPhoto2();
  }

  Future<void> updateSummaryOfLocalPhoto2() async {
    print("updateSummaryOfLocaoPhoto..");
    List newList = localPhotoDataManager.datetimes;
    Set ListOfDates = newList.toSet();
    print("updateSummaryOfLocalPhoto2 ListOfDates $ListOfDates");
    final map = Map<String, int>.fromIterable(ListOfDates,
        key: (item) => item,
        value: (item) => newList.where((c) => c == item).length);
    summaryOfPhotoData = map;
    global.summaryOfPhotoData = summaryOfPhotoData;
  }

  Future<void> updateSummaryOfPhotoData(String date, int num) async {
    summaryOfPhotoData[date] = num;
    updateIndexOfPhotoSummary += 1;
    if (updateIndexOfPhotoSummary > 3) {
      updateIndexOfPhotoSummary = 0;
      await writeSummaryOfGooglePhotoData();
      global.summaryOfPhotoData = summaryOfPhotoData;
    }
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

  Future writeSummaryOfGooglePhotoData() async {
    final Directory? directory = await getExternalStorageDirectory();
    final fileName = '${directory?.path}/summary_googlePhoto.csv';

    File file = File(fileName);

    print("write ${fileName}");
    await file.writeAsString('date,numberOfImages\n', mode: FileMode.write);

    print("writing... ${summaryOfPhotoData}");
    for (int i = 1; i < summaryOfPhotoData.length; i++) {
      var line = summaryOfPhotoData.keys.elementAt(i);
      await file.writeAsString('${line},${summaryOfPhotoData[line]}\n',
          mode: FileMode.append);
    }
  }

  Future<List> getSensorFileList() async {
    var directory = await getExternalStorageDirectories();
    Directory(directory!.first.path).create();
    var files = Glob("${directory.first.path}/sensorData/*_sensor.csv");
    fileList = List<String>.generate(
        files.listSync().length, (int index) => files.listSync()[index].path);
    return fileList;
  }

  void processAllSensorFiles() async {
    //subsample and write each sensor file to local

    final Directory? directory = await getExternalStorageDirectory();
    String fileName = Glob("${directory?.path}/$processedFileName")
        .listSync()
        .elementAt(0)
        .path;
    File file = File(fileName);

    await file.writeAsString(
        'time, longitude, latitude, accelX, accelY, accelZ, light, temperature, proximity, humidity\n',
        mode: FileMode.write);

    await getSensorFileList();
    for (int i = 0; i < fileList.length; i++) {
      // for (int i = 0; i < 2; i++) {
      List data = await openFile(fileList[i]);
      List subsampledData = await subsampleList(data, 50);
      await writeDataToProcessedFile(subsampledData);

      // for(int i=0; i< 9; i++){
      //
      // }
    }
  }

  Future<List> getProcessedSensorFile() async {
    final Directory? directory = await getExternalStorageDirectory();
    String fileName = Glob('${directory?.path}/$processedFileName')
        .listSync()
        .elementAt(0)
        .path;
    File file = File(fileName);

    List data = await openFile(file.path);
    processedSensorData = data;
    return data;
  }

  Future<int> writeDataToProcessedFile(List data) async {
    final Directory? directory = await getExternalStorageDirectory();
    String fileName = Glob('${directory?.path}/$processedFileName')
        .listSync()
        .elementAt(0)
        .path;
    File file = File(fileName);
    print("write ${file.path}");

    for (int i = 1; i < data.length; i++) {
      var line = data[i];
      // print(line.length);
      while (line.length < 10) {
        line.add('0');
      }
      print(line);
      await file.writeAsString(
          '${line[0]}, ${line[1]}, ${line[2]}, ${line[3]}'
          ',${line[4]}, ${line[5]}}\n',
          mode: FileMode.append);
    }
    return 0;
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

  void appendToFile() {}

  void getSensorData(sensorDataReader) {
    sensorDataAll = sensorDataReader.dailyDataAll;
    print(sensorDataAll);
  }
}
