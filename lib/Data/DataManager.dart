import 'dart:io';
import 'package:glob/list_local_fs.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:glob/glob.dart';
import 'package:test_location_2nd/Util/Util.dart';
import 'package:test_location_2nd/global.dart' as global;

enum sensorType {
  longitude,
  latitude,
  accelX,
  accelY,
  accelZ,
  light,
  temperature,
  proximity,
  humidity,
}

class DataManager {
  var sensorDataAll;
  var photoDataAll;

  List<String> fileList = [];
  List<dynamic> dataAll = [];
  List<dynamic> processedSensorData = [];
  Map summaryOfGooglePhotoData = {};

  String processedFileName = "sensor_processed.csv";
  List<DateTime> datesOfYear = [];
  int updateIndexOfGooglePhotoSummary = 0;

  DataManager(){
    // datesOfYear = getDaysInBetween(DateTime.parse("20220101"), DateTime.now());
    // processAllSensorFiles();
    // getProcessedSensorFile();
    readSummaryOfGooglePhotoData();
  }

  void updateSummaryOfGooglePhotoData(String date, int num){
    summaryOfGooglePhotoData[date] = num;
    updateIndexOfGooglePhotoSummary +=1;
    if(updateIndexOfGooglePhotoSummary > 5){
      writeSummaryOfGooglePhotoData();
      global.summaryOfGooglePhotoData = summaryOfGooglePhotoData;
    }
  }

  void readSummaryOfGooglePhotoData() async {
    final Directory? directory = await getExternalStorageDirectory();
    final File file = File('${directory?.path}/summary_googlePhoto.csv');
    print("read ${file.path}");
    var data = await openFile(file.path);

    print(data);
    for( int i = 0; i< data.length; i++){
      try {
        summaryOfGooglePhotoData[data[i][0].toString()] = data[i][1];
      } catch (e){
        print(e);
      }

    }
    global.summaryOfGooglePhotoData = summaryOfGooglePhotoData;
  }
  void writeSummaryOfGooglePhotoData() async{
    final Directory? directory = await getExternalStorageDirectory();
    final File file = File('${directory?.path}/summary_googlePhoto.csv');

    print("write ${file.path}");
    await file.writeAsString(
        'date,numberOfImages\n',
        mode: FileMode.write);
    print("writing... ${summaryOfGooglePhotoData}");
    for (int i = 1; i < summaryOfGooglePhotoData.length; i++) {
      var line = summaryOfGooglePhotoData.keys.elementAt(i);
      await file.writeAsString(
          '${line},${summaryOfGooglePhotoData[line]}\n',
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
    final File file = File('${directory?.path}/$processedFileName');

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
  Future<List> getProcessedSensorFile() async{
    final Directory? directory = await getExternalStorageDirectory();
    final File file = File('${directory?.path}/$processedFileName');

    List data = await openFile(file.path);
    processedSensorData = data;
    return data;

  }

  Future<int> writeDataToProcessedFile(List data) async {
    final Directory? directory = await getExternalStorageDirectory();
    final File file = File('${directory?.path}/$processedFileName');
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
          ',${line[4]}, ${line[5]}, ${line[6]}, ${line[7]}'
          ', ${line[8]}, ${line[9]}\n',
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
